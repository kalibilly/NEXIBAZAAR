from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout


def home(request):
    """Home page view"""
    context = {
        'page': 'home'
    }
    return render(request, 'home.html', context)


def shop(request):
    """Shop page view"""
    context = {
        'page': 'shop'
    }
    return render(request, 'shop.html', context)


def cart(request):
    """Shopping cart page view"""
    context = {
        'page': 'cart'
    }
    return render(request, 'cart.html', context)


def login_view(request):
    """Login page view (GET returns form, POST via API JS handles token)
    We also include a server-side path so that session authentication works when
    the API login is called with credentials included.
    """
    if request.user.is_authenticated:
        return redirect('home')

    if request.method == 'POST':
        # fallback: standard form submission
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('home')
        messages.error(request, 'Invalid username or password')

    context = {
        'page': 'login'
    }
    return render(request, 'login.html', context)


def register_view(request):
    """Register page view"""
    if request.user.is_authenticated:
        return redirect('home')

    if request.method == 'POST':
        # simple server-side registration; JS handles API call
        # Here we could also process the form and create user, but
        # the JS registration path usually takes care of it.
        pass

    context = {
        'page': 'register'
    }
    return render(request, 'register.html', context)


@login_required(login_url='login')
def orders_view(request):
    """Orders page view"""
    context = {
        'page': 'orders'
    }
    return render(request, 'orders.html', context)


@login_required(login_url='login')
def seller_dashboard(request):
    """Seller dashboard template"""
    # dashboard data will be fetched by AJAX from APIs
    context = {
        'page': 'seller_dashboard'
    }
    return render(request, 'seller_dashboard.html', context)


@login_required(login_url='login')
def profile_view(request):
    """Profile page – view & update user info"""
    user = request.user
    if request.method == 'POST':
        # update fields
        user.first_name = request.POST.get('first_name', user.first_name)
        user.last_name = request.POST.get('last_name', user.last_name)
        user.email = request.POST.get('email', user.email)
        # profile account type
        acct = request.POST.get('account_type')
        if acct and hasattr(user, 'profile'):
            user.profile.account_type = acct
            user.profile.save()
        user.save()
        messages.success(request, 'Profile updated successfully')
        return redirect('profile')

    context = {'page': 'profile', 'user': user}
    return render(request, 'profile.html', context)


def logout_view(request):
    """Simple logout that clears Django session and redirects"""
    logout(request)
    return redirect('login')
