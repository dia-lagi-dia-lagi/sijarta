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
import uuid
from datetime import date


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


from django.db import connection, IntegrityError
import uuid
from datetime import date

import uuid
from django.db import connection, IntegrityError
from datetime import date
from django.http import JsonResponse

def insert_into_tr_pembelian_voucher(request):
    if request.method == 'POST':
        try:
            # Retrieve POST data from the form
            # id_pelanggan = request.POST.get('id_pelanggan')  
            id_pelanggan = '8750a667-8542-4e7f-aa97-f6ecbeddf14e'
            id_voucher = request.POST.get('id_voucher')  # Similarly, get voucher ID
            id_metode_bayar = request.POST.get('metode_pembayaran')  # Method of payment from form

            
            if not id_pelanggan or not id_voucher or not id_metode_bayar:
                return JsonResponse({'error': 'Missing required form data'}, status=400)

            # Generate a new UUID for the transaction
            id_tr_pembelian_voucher = uuid.uuid4()  
            # id_tr_pembelian_voucher = 'dd65e64c-1854-4d23-b778-f877986f5beb'
            tgl_awal = date.today()  # Today's date for 'tgl_awal'
            
            # Set the default value for 'telah_digunakan' (not used yet)
            telah_digunakan = 0

            # Open a cursor to perform the SQL operation
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO sijarta.tr_pembelian_voucher (
                        id_tr_pembelian_voucher, tgl_awal, tgl_akhir, telah_digunakan,
                        id_pelanggan, id_voucher, id_metode_bayar
                    )
                    VALUES (%s, %s, NULL, %s, %s, %s, %s)
                """, (id_tr_pembelian_voucher, tgl_awal, telah_digunakan,
                      id_pelanggan, id_voucher, id_metode_bayar))
            
            # Return success response
            return JsonResponse({'message': 'Data inserted successfully!'}, status=200)

        except IntegrityError as e:
            # Handle database integrity errors (e.g., foreign key violations, unique constraint violations)
            error_message = f"Integrity error occurred: {str(e)}"
            return JsonResponse({'error': error_message}, status=400)

        except Exception as e:
            # Catch any other unexpected errors
            error_message = f"An unexpected error occurred: {str(e)}"
            return JsonResponse({'error': error_message}, status=500)
 



def fetch_mypay():
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM DISKON NATURAL JOIN VOUCHER")
        rows = cursor.fetchall()
    return rows


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


def fetch_service_testimony(id_tr_pemesanan_jasa: str):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                id_tr_pemesanan_jasa, 
                pl.nama AS nama_pelanggan, 
                pk.nama AS nama_pekerja, 
                t.tgl, 
                t.teks, 
                t.rating
            FROM TESTIMONI t
            NATURAL JOIN TR_PEMESANAN_JASA tpj
            JOIN USERS pl ON pl.id_user = tpj.id_pelanggan
            JOIN USERS pk ON pk.id_user = tpj.id_pekerja
            WHERE t.id_tr_pemesanan_jasa = %s
        """, [id_tr_pemesanan_jasa])
        rows = cursor.fetchall()
    return rows


def fetch_user_testimony(id_tr_pemesanan_jasa: str):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                id_tr_pemesanan_jasa, 
                pl.nama AS nama_pelanggan, 
                pk.nama AS nama_pekerja, 
                t.tgl, 
                t.teks, 
                t.rating
            FROM TESTIMONI t
            JOIN TR_PEMESANAN_JASA tpj ON tpj.id_tr_pemesanan_jasa = t.id_tr_pemesanan_jasa
            JOIN USERS pl ON pl.id_user = tpj.id_pelanggan
            JOIN USERS pk ON pk.id_user = tpj.id_pekerja
            WHERE t.id_tr_pemesanan_jasa = %s
        """, [id_tr_pemesanan_jasa])
        rows = cursor.fetchall()
    return rows


from django.http import JsonResponse
from django.db import connection, IntegrityError
import uuid
from datetime import date

def insert_into_testimoni(request):
    if request.method == 'POST':
        try:
            # Retrieve POST data from the form
            # id_pelanggan = request.POST.get('id_pelanggan')  # Example if needed
            id_pelanggan = '8750a667-8542-4e7f-aa97-f6ecbeddf14e'  # Dummy ID for example
            teks = request.POST.get('teks')  # Text for the testimonial
            rating = request.POST.get('rating')  # Rating value
            id_tr_pemesanan_jasa = request.POST.get('id_tr_pemesanan_jasa')  # Generate a new UUID for the testimonial
            
            if not teks or not rating or not id_tr_pemesanan_jasa:
                return JsonResponse({'error': 'Missing required form data (teks or rating)'}, status=400)

            # Ensure rating is an integer between 1 and 5
            try:
                rating = int(rating)
                if rating < 1 or rating > 5:
                    return JsonResponse({'error': 'Rating must be between 1 and 5'}, status=400)
            except ValueError:
                return JsonResponse({'error': 'Invalid rating value'}, status=400)
    
            tgl = date.today()  # Today's date for 'tgl'
            
            # Open a cursor to perform the SQL operation
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO TESTIMONI (
                        id_tr_pemesanan_jasa, tgl, teks, rating
                    )
                    VALUES (%s, %s, %s, %s)
                """, (id_tr_pemesanan_jasa, tgl, teks, rating))
            
            # Return success response
            return JsonResponse({'message': 'Testimonial inserted successfully!'}, status=200)

        except IntegrityError as e:
            # Handle database integrity errors (e.g., foreign key violations, unique constraint violations)
            error_message = f"Integrity error occurred: {str(e)}"
            return JsonResponse({'error': error_message}, status=400)

        except Exception as e:
            # Catch any other unexpected errors
            error_message = f"An unexpected error occurred: {str(e)}"
            return JsonResponse({'error': error_message}, status=500)
        



def delete_testimoni(request):
    if request.method == 'POST':
        try:
            # Retrieve POST data from the form
            id_tr_pemesanan_jasa = request.POST.get('id_tr_pemesanan_jasa')
            
            if not id_tr_pemesanan_jasa:
                return JsonResponse({'error': 'Missing required form data (id_tr_pemesanan_jasa)'}, status=400)

            # Open a cursor to perform the SQL operation
            with connection.cursor() as cursor:
                # Check if the testimonial exists before attempting to delete
                cursor.execute("SELECT 1 FROM TESTIMONI WHERE id_tr_pemesanan_jasa = %s", [id_tr_pemesanan_jasa])
                if cursor.fetchone() is None:
                    return JsonResponse({'error': 'Testimonial not found for the given id_tr_pemesanan_jasa'}, status=404)
                
                # Perform the deletion
                cursor.execute("DELETE FROM TESTIMONI WHERE id_tr_pemesanan_jasa = %s", [id_tr_pemesanan_jasa])
            
            # Return success response
            return JsonResponse({'message': 'Testimonial deleted successfully!'}, status=200)

        except IntegrityError as e:
            # Handle database integrity errors (e.g., foreign key violations, unique constraint violations)
            error_message = f"Integrity error occurred: {str(e)}"
            return JsonResponse({'error': error_message}, status=400)

        except Exception as e:
            # Catch any other unexpected errors
            error_message = f"An unexpected error occurred: {str(e)}"
            return JsonResponse({'error': error_message}, status=500)

    

    





