from rest_framework import permissions
from .models import Profile


class IsSellerOnly(permissions.BasePermission):
    """
    Permission to check if user is a seller.
    """
    def has_permission(self, request, view):
        return (request.user and 
                request.user.is_authenticated and 
                hasattr(request.user, 'profile') and
                request.user.profile.account_type == Profile.SELLER)


class IsCustomerOnly(permissions.BasePermission):
    """
    Permission to check if user is a customer.
    """
    def has_permission(self, request, view):
        return (request.user and 
                request.user.is_authenticated and 
                hasattr(request.user, 'profile') and
                request.user.profile.account_type == Profile.CUSTOMER)


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request
        if request.method in permissions.SAFE_METHODS:
            return True
        # Write permissions are only allowed to the owner
        return obj.user == request.user


class IsProductOwnerOrReadOnly(permissions.BasePermission):
    """
    Object-level permission to only allow sellers who own the product to edit it.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request
        if request.method in permissions.SAFE_METHODS:
            return True
        # Write permissions are only allowed to the seller who created the product
        return obj.seller == request.user


class IsOrderOwnerOrSellerOfProduct(permissions.BasePermission):
    """
    Object-level permission to only allow order owner or sellers of products in the order.
    """
    def has_object_permission(self, request, view, obj):
        # Order owner can always view/modify their order
        if obj.user == request.user:
            return True
        # Sellers can view orders containing their products
        if hasattr(request.user, 'profile') and request.user.profile.account_type == Profile.SELLER:
            return obj.items.filter(product__seller=request.user).exists()
        return False


class IsAdmin(permissions.BasePermission):
    """
    Permission to check if user is admin.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_staff
