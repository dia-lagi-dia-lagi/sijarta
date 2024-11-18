from django.urls import path
from . import views

app_name = 'service'

urlpatterns = [
    path('', views.homepage, name='homepage'),
    path('subcategory/pengguna/', views.subcategory_detail_pengguna, name='subcategory_detail_pengguna'),
    path('subcategory/pekerja/', views.subcategory_detail_pekerja, name='subcategory_detail_pekerja'),
    path('worker/worker_id/', views.worker_profile, name='worker_profile'),
    path('pesanan/user_id/', views.view_orders, name='view_orders'),
]