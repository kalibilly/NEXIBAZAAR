from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
from .models import Profile, Wallet


@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    if created:
        profile = Profile.objects.create(user=instance)
        # create wallet for all users, seller may use it later
        Wallet.objects.create(user=instance)
    else:
        # make sure profile exists
        profile, _ = Profile.objects.get_or_create(user=instance)
        profile.save()
        Wallet.objects.get_or_create(user=instance)
