from django.urls import path
from mypay.views import mypay_home, transaksi_mypay, pekerjaan_jasa, status_pekerjaan_jasa

app_name = 'mypay'

urlpatterns = [
    path('', mypay_home, name='mypay_home'),
    path('transaksi/', transaksi_mypay, name='transaksi_mypay'),
    path('pekerjaan/', pekerjaan_jasa, name='pekerjaan_jasa'),
    path('status/', status_pekerjaan_jasa, name='status_pekerjaan_jasa'),
]
