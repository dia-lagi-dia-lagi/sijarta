from django.urls import path
from user_profile.views import show_profile

app_name = 'user_profile'

urlpatterns = [
    path('profile', show_profile, name='profile'),
]