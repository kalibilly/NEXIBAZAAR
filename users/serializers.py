from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Wallet, BankAccount, Profile


class ProfileSerializer(serializers.ModelSerializer):
    """Serializer for user profile with role information"""
    class Meta:
        model = Profile
        fields = ['account_type']


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model with profile information"""
    profile = ProfileSerializer(read_only=True)
    account_type = serializers.SerializerMethodField()
    is_seller = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'account_type', 'is_seller', 'profile']

    def get_account_type(self, obj):
        if hasattr(obj, 'profile'):
            return obj.profile.account_type
        return None

    def get_is_seller(self, obj):
        if hasattr(obj, 'profile'):
            return obj.profile.account_type == Profile.SELLER
        return False


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration"""
    password = serializers.CharField(write_only=True, min_length=6)
    password2 = serializers.CharField(write_only=True, min_length=6)
    account_type = serializers.ChoiceField(
        choices=[('customer','Customer'),('seller','Seller')],
        default='customer',
        write_only=True,
        required=False
    )

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2', 'first_name', 'last_name', 'account_type']

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({'password': 'Passwords must match.'})
        return data

    def create(self, validated_data):
        account_type = validated_data.pop('account_type', 'customer')
        validated_data.pop('password2')
        user = User.objects.create_user(**validated_data)
        # profile is created by signal; update account_type value
        user.profile.account_type = account_type
        user.profile.save()
        return user


class BankAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = BankAccount
        fields = ['id', 'bank_name', 'account_number', 'ifsc_code', 'created_at']


class WalletSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wallet
        fields = ['balance', 'user']
        read_only_fields = ['user']


class UserLoginSerializer(serializers.Serializer):
    """Serializer for user login"""
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
