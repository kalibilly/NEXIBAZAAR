from rest_framework import serializers
from products.serializers import ProductSerializer
from .models import Order, OrderItem


class OrderItemSerializer(serializers.ModelSerializer):
    """Serializer for OrderItem model"""
    product = ProductSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = OrderItem
        fields = ['id', 'product', 'product_id', 'quantity', 'price', 'created_at']


class OrderSerializer(serializers.ModelSerializer):
    """Serializer for Order model"""
    items = OrderItemSerializer(many=True, read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'user', 'user_email', 'order_number', 'total_price', 'status',
            'payment_status', 'razorpay_order_id', 'razorpay_payment_id',
            'otp_confirmed', 'delivery_otp', 'shipping_address', 'phone', 'items',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['order_number', 'total_price', 'created_at', 'updated_at',
                            'payment_status', 'razorpay_order_id', 'razorpay_payment_id', 'delivery_otp']


class OrderCreateSerializer(serializers.Serializer):
    """Serializer for creating orders"""
    shipping_address = serializers.CharField()
    phone = serializers.CharField()
    items = serializers.ListField(child=serializers.DictField())

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError("Order must contain at least one item")
        return value
