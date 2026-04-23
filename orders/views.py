from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from django.conf import settings
import razorpay
from products.models import Product
from .models import Order, OrderItem
from .serializers import OrderSerializer, OrderCreateSerializer
from users.models import Profile
from users.permissions import IsAdmin


class OrderViewSet(viewsets.ModelViewSet):
    """ViewSet for Order model"""
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Return orders for the authenticated user or seller's orders"""
        user = self.request.user
        # Customers see their own orders
        if hasattr(user, 'profile') and user.profile.account_type == Profile.SELLER:
            # Sellers see orders containing their products
            return Order.objects.filter(
                user=user
            ) | Order.objects.filter(
                items__product__seller=user
            ).distinct()
        # Default: return user's own orders
        return Order.objects.filter(user=user)

    def create(self, request, *args, **kwargs):
        """Create a new order"""
        serializer = OrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Generate order number
        last_order = Order.objects.latest('id') if Order.objects.exists() else None
        order_number = f"ORD-{(last_order.id + 1 if last_order else 1):05d}"

        # Create order
        import random
        otp_code = str(random.randint(100000, 999999))
        order = Order.objects.create(
            user=request.user,
            order_number=order_number,
            shipping_address=serializer.validated_data['shipping_address'],
            phone=serializer.validated_data['phone'],
            delivery_otp=otp_code,
        )

        total_price = 0
        # Create order items
        for item in serializer.validated_data['items']:
            try:
                product = Product.objects.get(id=item['product_id'])
                quantity = item['quantity']
                price = product.price * quantity
                total_price += price

                OrderItem.objects.create(
                    order=order,
                    product=product,
                    quantity=quantity,
                    price=product.price
                )
            except Product.DoesNotExist:
                order.delete()
                return Response(
                    {'error': f"Product with id {item['product_id']} not found"},
                    status=status.HTTP_400_BAD_REQUEST
                )

        order.total_price = total_price
        order.save()

        return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)

    def retrieve(self, request, *args, **kwargs):
        """Get order details"""
        order = self.get_object()
        # Check if user is the order owner or a seller with products in the order
        is_owner = order.user == request.user
        is_seller_with_product = (
            hasattr(request.user, 'profile') and 
            request.user.profile.account_type == Profile.SELLER and
            order.items.filter(product__seller=request.user).exists()
        )
        
        if not (is_owner or is_seller_with_product):
            return Response(
                {'error': 'You do not have permission to view this order'},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = self.get_serializer(order)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def my_orders(self, request):
        """Get all orders for the current user"""
        orders = self.get_queryset()
        serializer = self.get_serializer(orders, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['patch'], permission_classes=[IsAdmin])
    def update_status(self, request, pk=None):
        """Update order status (admin only)"""
        order = self.get_object()
        new_status = request.data.get('status')
        
        if new_status in dict(Order.ORDER_STATUS_CHOICES):
            order.status = new_status
            order.save()
            return Response(OrderSerializer(order).data)
        
        return Response(
            {'error': 'Invalid status'},
            status=status.HTTP_400_BAD_REQUEST
        )

    @action(detail=True, methods=['post'])
    def create_payment(self, request, pk=None):
        """Create a Razorpay order and return order id"""
        order = self.get_object()
        # Only order owner can create payment
        if order.user != request.user:
            return Response(
                {'error': 'You cannot create payment for this order'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if order.payment_status != 'unpaid':
            return Response({'error': 'Payment already initiated'}, status=status.HTTP_400_BAD_REQUEST)

        # initialize Razorpay client using credentials from settings (decouple)
        client = razorpay.Client(
            auth=(
                getattr(settings, 'RAZORPAY_KEY', None) or '',
                getattr(settings, 'RAZORPAY_SECRET', None) or ''
            )
        )

        amount_paise = int(order.total_price * 100)
        try:
            razorpay_order = client.order.create({
                'amount': amount_paise,
                'currency': 'INR',
                'payment_capture': 0,  # capture manually after delivery confirmation
                'receipt': f'order_{order.id}'
            })
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        order.razorpay_order_id = razorpay_order.get('id')
        order.save()
        return Response({'razorpay_order_id': order.razorpay_order_id})

    @action(detail=True, methods=['post'])
    def verify_payment(self, request, pk=None):
        """Verify razorpay payment signature"""
        order = self.get_object()
        # Only order owner can verify payment
        if order.user != request.user:
            return Response(
                {'error': 'You cannot verify payment for this order'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        payment_id = request.data.get('razorpay_payment_id')
        signature = request.data.get('razorpay_signature')
        if not payment_id or not signature:
            return Response({'error': 'missing payment data'}, status=status.HTTP_400_BAD_REQUEST)

        client = razorpay.Client(
            auth=(
                getattr(settings, 'RAZORPAY_KEY', None) or '',
                getattr(settings, 'RAZORPAY_SECRET', None) or ''
            )
        )

        try:
            params = {
                'razorpay_order_id': order.razorpay_order_id,
                'razorpay_payment_id': payment_id,
                'razorpay_signature': signature,
            }
            client.utility.verify_payment_signature(params)
        except razorpay.errors.SignatureVerificationError:
            return Response({'error': 'signature mismatch'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        order.razorpay_payment_id = payment_id
        order.razorpay_signature = signature
        order.payment_status = 'paid'
        order.save()
        return Response({'status': 'payment verified'})

    @action(detail=True, methods=['post'])
    def confirm_delivery(self, request, pk=None):
        """Customer confirms delivery via OTP and releases payment to sellers"""
        order = self.get_object()
        # Only order owner can confirm delivery
        if order.user != request.user:
            return Response(
                {'error': 'Only order owner can confirm delivery'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        otp = request.data.get('otp')
        if not otp or otp != order.delivery_otp:
            return Response({'error': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)
        order.otp_confirmed = True
        order.status = 'delivered'
        order.payment_status = 'released'
        order.save()
        # distribute funds to sellers
        for item in order.items.all():
            seller = item.product.seller
            if seller and hasattr(seller, 'wallet'):
                amount = item.price * item.quantity
                seller.wallet.deposit(amount)
        return Response(OrderSerializer(order).data)


