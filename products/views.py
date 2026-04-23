from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth.models import User
from .models import Product, Category
from .serializers import ProductSerializer, CategorySerializer
from users.models import Profile
from users.permissions import IsSellerOnly, IsProductOwnerOrReadOnly


class CategoryViewSet(viewsets.ModelViewSet):
    """ViewSet for Category model"""
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    permission_classes = [AllowAny]  # Allow anyone to view categories


class ProductViewSet(viewsets.ModelViewSet):
    """ViewSet for Product model"""
    queryset = Product.objects.filter(is_active=True)
    serializer_class = ProductSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description', 'category__name']
    ordering_fields = ['name', 'price', 'created_at']
    permission_classes = [IsProductOwnerOrReadOnly]

    def get_queryset(self):
        """Filter products by category if provided, or by seller when using my_products"""
        queryset = super().get_queryset()
        category = self.request.query_params.get('category', None)
        if category:
            queryset = queryset.filter(category__id=category)
        return queryset

    def get_permissions(self):
        """
        Override permissions based on action
        """
        if self.action in ['list', 'retrieve', 'featured', 'by_category']:
            permission_classes = [AllowAny]
        elif self.action == 'create':
            permission_classes = [IsSellerOnly]
        elif self.action in ['update', 'partial_update', 'destroy']:
            permission_classes = [IsProductOwnerOrReadOnly]
        elif self.action == 'my_products':
            permission_classes = [IsSellerOnly]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]

    def perform_create(self, serializer):
        # assign seller as current user
        serializer.save(seller=self.request.user)

    def perform_update(self, serializer):
        # ensure only owner can update
        product = self.get_object()
        if product.seller != self.request.user:
            raise PermissionError("You can only update your own products.")
        serializer.save()

    def perform_destroy(self, instance):
        # ensure only owner can delete
        if instance.seller != self.request.user:
            raise PermissionError("You can only delete your own products.")
        instance.delete()

    @action(detail=False, methods=['get'], permission_classes=[IsSellerOnly])
    def my_products(self, request):
        """List products created by the authenticated seller"""
        user = request.user
        products = self.queryset.filter(seller=user)
        serializer = self.get_serializer(products, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], permission_classes=[AllowAny])
    def by_category(self, request):
        """Get products grouped by category"""
        categories = Category.objects.prefetch_related('products')
        data = []
        for category in categories:
            products = category.products.filter(is_active=True)
            data.append({
                'category': CategorySerializer(category).data,
                'products': ProductSerializer(products, many=True).data
            })
        return Response(data)

    @action(detail=False, methods=['get'], permission_classes=[AllowAny])
    def featured(self, request):
        """Get featured products (first 10)"""
        products = Product.objects.filter(is_active=True)[:10]
        serializer = self.get_serializer(products, many=True)
        return Response(serializer.data)
