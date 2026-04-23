from django.db import models
from django.contrib.auth.models import User


class Wallet(models.Model):
    """Simple wallet for sellers"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='wallet')
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    def deposit(self, amount):
        self.balance += amount
        self.save()

    def withdraw(self, amount):
        if amount <= self.balance:
            self.balance -= amount
            self.save()
            return True
        return False

    def __str__(self):
        return f"Wallet({self.user.username}): {self.balance}"  


class BankAccount(models.Model):
    """Seller bank account details for withdrawal"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bank_accounts')
    bank_name = models.CharField(max_length=255)
    account_number = models.CharField(max_length=50)
    ifsc_code = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.bank_name} - {self.account_number}"
class Profile(models.Model):
    CUSTOMER = 'customer'
    SELLER = 'seller'
    ACCOUNT_TYPE_CHOICES = [
        (CUSTOMER, 'Customer'),
        (SELLER, 'Seller'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    account_type = models.CharField(max_length=10, choices=ACCOUNT_TYPE_CHOICES, default=CUSTOMER)
    # seller-specific fields can be added later if needed

    def __str__(self):
        return f"{self.user.username} ({self.account_type})"
