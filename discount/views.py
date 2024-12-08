from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.utils.html import strip_tags
from django.http import JsonResponse, HttpResponse
from django.contrib.auth.models import User
from datetime import datetime
from django.core import serializers
import uuid
from django.shortcuts import get_object_or_404
from django.contrib.auth.decorators import login_required
import json
from django.db import connections, connection

# @login_required(login_url='/auth/login/')
def show_discount(request):
    promo = fetch_promo()
    voucher = fetch_voucher()
    metode_bayar = fetch_pay_option()

    context = {
        'user': request.user,
        'promos': promo,
        'vouchers': voucher,
        'metode_pembayaran' : metode_bayar,

    }

    return render(request, "discount.html", context)


def fetch_voucher():
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM DISKON NATURAL JOIN VOUCHER")
        rows = cursor.fetchall()
    return rows

def fetch_promo():
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM PROMO")
        rows = cursor.fetchall()
    return rows

def fetch_pay_option():
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM METODE_BAYAR")
        rows = cursor.fetchall()
    return rows




