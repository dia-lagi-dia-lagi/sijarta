from django.urls import path
from discount.views import show_discount

app_name = 'discount'

urlpatterns = [
    path('', show_discount, name='show_discount'),
]