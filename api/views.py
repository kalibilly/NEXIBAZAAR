from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(['GET'])
def api_root(request):
    """API root endpoint"""
    return Response({
        'message': 'Welcome to NexiBazaar E-Commerce API',
        'version': '1.0.0',
        'endpoints': {
            'products': request.build_absolute_uri('/api/products/'),
            'categories': request.build_absolute_uri('/api/categories/'),
            'orders': request.build_absolute_uri('/api/orders/'),
            'users': request.build_absolute_uri('/api/users/'),
            'auth/register': request.build_absolute_uri('/api/users/register/'),
            'auth/login': request.build_absolute_uri('/api/users/login/'),
            'auth/profile': request.build_absolute_uri('/api/users/profile/'),
        }
    })
