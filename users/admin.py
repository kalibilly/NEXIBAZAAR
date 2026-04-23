from django.contrib import admin
from .models import Profile, Wallet, BankAccount


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'account_type']
    search_fields = ['user__username', 'account_type']


@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ['user', 'balance']
    search_fields = ['user__username']


@admin.register(BankAccount)
class BankAccountAdmin(admin.ModelAdmin):
    list_display = ['user', 'bank_name', 'account_number', 'ifsc_code']
    search_fields = ['user__username', 'bank_name', 'account_number']
