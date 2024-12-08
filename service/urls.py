from django.urls import path
from . import views

app_name = 'service'

urlpatterns = [
    path('home/', views.homepage, name='homepage'),
    path('subcategory/<uuid:subcategory_id>/', views.subcategory_detail, name='subcategory_detail'),
    path('worker/worker_id/', views.worker_profile, name='worker_profile'),
    path('pesanan/<uuid:user_id>/', views.view_orders, name='view_orders'),
    path('api/validate-discount/', views.validate_discount, name='validate_discount'),
    path('api/submit-testimonial/', views.submit_testimonial, name='submit_testimonial'),
    path('api/cancel-order/', views.cancel_order, name='cancel_order'),
    path('api/submit-order/', views.submit_order, name='submit_order'),
]