from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from .serializers import UserSerializer, UserRegistrationSerializer, UserLoginSerializer, WalletSerializer, BankAccountSerializer
from .models import Wallet, BankAccount, Profile
from .permissions import IsSellerOnly
from orders.models import Order
from products.models import Product


class UserViewSet(viewsets.ModelViewSet):
    """ViewSet for User model"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

    def get_permissions(self):
        """
        Override permissions based on action
        """
        if self.action in ['register', 'login']:
            permission_classes = [AllowAny]
        elif self.action in ['logout', 'profile', 'update_profile', 'wallet', 'bank_accounts', 'withdraw']:
            permission_classes = [IsAuthenticated]
        elif self.action in ['seller_orders']:
            permission_classes = [IsSellerOnly]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        """Register a new user"""
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # log the user in via session also
            login(request, user)
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        """Login user"""
        serializer = UserLoginSerializer(data=request.data)
        if serializer.is_valid():
            user = authenticate(
                username=serializer.validated_data['username'],
                password=serializer.validated_data['password']
            )
            if user:
                # create session
                login(request, user)
                token, created = Token.objects.get_or_create(user=user)
                return Response({
                    'user': UserSerializer(user).data,
                    'token': token.key
                }, status=status.HTTP_200_OK)
            return Response(
                {'error': 'Invalid credentials'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def logout(self, request):
        """Logout user"""
        # clear both token and session
        request.user.auth_token.delete()
        logout(request)
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def profile(self, request):
        """Get current user profile"""
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['put'], permission_classes=[IsAuthenticated])
    def update_profile(self, request):
        """Update user profile"""
        user = request.user
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            # update account_type if provided
            account_type = request.data.get('account_type')
            if account_type and hasattr(user, 'profile'):
                user.profile.account_type = account_type
                user.profile.save()
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # Seller-specific actions
    @action(detail=False, methods=['get'], permission_classes=[IsSellerOnly])
    def seller_orders(self, request):
        """List orders that include products belonging to the seller"""
        user = request.user
        orders = Order.objects.filter(items__product__seller=user).distinct()
        # reuse order serializer
        from orders.serializers import OrderSerializer
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def wallet(self, request):
        """Get wallet balance - only for seller"""
        user = request.user
        if not hasattr(user, 'profile') or user.profile.account_type != Profile.SELLER:
            return Response(
                {'error': 'Only sellers can access wallet'},
                status=status.HTTP_403_FORBIDDEN
            )
        wallet, _ = Wallet.objects.get_or_create(user=user)
        serializer = WalletSerializer(wallet)
        return Response(serializer.data)

    @action(detail=False, methods=['get', 'post'], permission_classes=[IsAuthenticated])
    def bank_accounts(self, request):
        """Get or create bank accounts - only for seller"""
        user = request.user
        if not hasattr(user, 'profile') or user.profile.account_type != Profile.SELLER:
            return Response(
                {'error': 'Only sellers can manage bank accounts'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if request.method == 'GET':
            accounts = BankAccount.objects.filter(user=user)
            serializer = BankAccountSerializer(accounts, many=True)
            return Response(serializer.data)
        else:
            # create new bank account
            serializer = BankAccountSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save(user=user)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def withdraw(self, request):
        """Withdraw funds from wallet - only for seller"""
        user = request.user
        if not hasattr(user, 'profile') or user.profile.account_type != Profile.SELLER:
            return Response(
                {'error': 'Only sellers can withdraw funds'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        amount = request.data.get('amount')
        wallet, _ = Wallet.objects.get_or_create(user=user)
        try:
            amount = float(amount)
        except Exception:
            return Response({'error': 'Invalid amount'}, status=status.HTTP_400_BAD_REQUEST)
        if wallet.withdraw(amount):
            # in real system, initiate transfer to bank account pipeline
            return Response({'status': 'withdrawal requested', 'remaining_balance': wallet.balance})
        return Response({'error': 'insufficient funds'}, status=status.HTTP_400_BAD_REQUEST)
