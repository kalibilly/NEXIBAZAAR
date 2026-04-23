from django.urls import path, include
from .views import api_root

urlpatterns = [
    path('', api_root, name='api_root'),
    path('', include('products.urls')),
    path('', include('orders.urls')),
    path('', include('users.urls')),
]
