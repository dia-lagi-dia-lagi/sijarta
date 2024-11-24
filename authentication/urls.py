from django.urls import path
from authentication.views import login_user, register

app_name = 'authentication'

urlpatterns = [
    path('login', login_user, name='login'),
    path('register', register, name='register'),
]