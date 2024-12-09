from django.urls import path
from discount.views import show_discount, insert_into_tr_pembelian_voucher

app_name = 'discount'

urlpatterns = [
    path('discount/', show_discount, name='show_discount'),
    path('submit/', insert_into_tr_pembelian_voucher, name='insert_into_tr_pembelian_voucher')
]