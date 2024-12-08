from django.shortcuts import render
from django.db import connection

def homepage(request):
    try:
        selected_category = request.GET.get('category', 'all')
        search_query = request.GET.get('search', '').strip()
        
        # First get all categories for the dropdown
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT DISTINCT kj.nama_kategori
                FROM SIJARTA.KATEGORI_JASA kj
                ORDER BY kj.nama_kategori
            """)
            categories_list = [row[0] for row in cursor.fetchall()]

        # Then get the filtered data based on selection
        with connection.cursor() as cursor:
            if selected_category.lower() == 'all' and not search_query:
                # No filter applied
                cursor.execute("""
                    SELECT kj.id_kategori_jasa, kj.nama_kategori, 
                           json_agg(
                               json_build_object(
                                   'id', sj.id_subkategori,
                                   'name', sj.nama_subkategori
                               )
                           ) as subcategories
                    FROM SIJARTA.KATEGORI_JASA kj
                    LEFT JOIN SIJARTA.SUBKATEGORI_JASA sj 
                    ON kj.id_kategori_jasa = sj.id_kategori_jasa
                    GROUP BY kj.id_kategori_jasa, kj.nama_kategori
                    ORDER BY kj.nama_kategori
                """)
            elif selected_category.lower() != 'all' and not search_query:
                # Only category filter
                cursor.execute("""
                    SELECT kj.id_kategori_jasa, kj.nama_kategori, 
                           json_agg(
                               json_build_object(
                                   'id', sj.id_subkategori,
                                   'name', sj.nama_subkategori
                               )
                           ) as subcategories
                    FROM SIJARTA.KATEGORI_JASA kj
                    LEFT JOIN SIJARTA.SUBKATEGORI_JASA sj 
                    ON kj.id_kategori_jasa = sj.id_kategori_jasa
                    WHERE kj.nama_kategori = %s
                    GROUP BY kj.id_kategori_jasa, kj.nama_kategori
                    ORDER BY kj.nama_kategori
                """, [selected_category])
            elif selected_category.lower() == 'all' and search_query:
                # Only search filter - Modified to filter subcategories while keeping category structure
                cursor.execute("""
                    SELECT kj.id_kategori_jasa, kj.nama_kategori, 
                        json_agg(
                            CASE 
                                WHEN sj.id_subkategori IS NULL THEN NULL
                                WHEN LOWER(sj.nama_subkategori) LIKE LOWER(%s) THEN
                                    json_build_object(
                                        'id', sj.id_subkategori,
                                        'name', sj.nama_subkategori
                                    )
                            END
                        ) filter (where sj.id_subkategori is not null) as subcategories
                    FROM SIJARTA.KATEGORI_JASA kj
                    LEFT JOIN SIJARTA.SUBKATEGORI_JASA sj 
                    ON kj.id_kategori_jasa = sj.id_kategori_jasa
                    WHERE EXISTS (
                        SELECT 1 
                        FROM SIJARTA.SUBKATEGORI_JASA sub 
                        WHERE sub.id_kategori_jasa = kj.id_kategori_jasa 
                        AND LOWER(sub.nama_subkategori) LIKE LOWER(%s)
                    )
                    GROUP BY kj.id_kategori_jasa, kj.nama_kategori
                    ORDER BY kj.nama_kategori
                """, [f'%{search_query}%', f'%{search_query}%'])
            else:
                # Both category and search filters - Modified to filter subcategories
                cursor.execute("""
                    SELECT kj.id_kategori_jasa, kj.nama_kategori, 
                        json_agg(
                            CASE 
                                WHEN sj.id_subkategori IS NULL THEN NULL
                                WHEN LOWER(sj.nama_subkategori) LIKE LOWER(%s) THEN
                                    json_build_object(
                                        'id', sj.id_subkategori,
                                        'name', sj.nama_subkategori
                                    )
                            END
                        ) filter (where sj.id_subkategori is not null) as subcategories
                    FROM SIJARTA.KATEGORI_JASA kj
                    LEFT JOIN SIJARTA.SUBKATEGORI_JASA sj 
                    ON kj.id_kategori_jasa = sj.id_kategori_jasa
                    WHERE kj.nama_kategori = %s
                    AND EXISTS (
                        SELECT 1 
                        FROM SIJARTA.SUBKATEGORI_JASA sub 
                        WHERE sub.id_kategori_jasa = kj.id_kategori_jasa 
                        AND LOWER(sub.nama_subkategori) LIKE LOWER(%s)
                    )
                    GROUP BY kj.id_kategori_jasa, kj.nama_kategori
                    ORDER BY kj.nama_kategori
                """, [f'%{search_query}%', selected_category, f'%{search_query}%'])

            rows = cursor.fetchall()
            categories_dict = [
                {
                    'name': row[1],
                    'subcategories': [sub for sub in row[2] if sub is not None] if row[2] else []
                }
                for row in rows
            ]

            context = {
                'categories_dict': categories_dict,
                'categories_list': categories_list,
                'selected_category': selected_category,
                'search_query': search_query
            }
            
            return render(request, 'service/homepage.html', context)
            
    except Exception as e:
        print(f"Database Error: {str(e)}")
        return render(request, 'service/homepage.html', {'error': str(e)})

def subcategory_detail(request, subcategory_id):
    # Simulate user authentication by selecting specific users
    # For testing, we'll use these IDs but in production this would come from auth
    test_user_id = '8192ca83-c52d-4350-8fa5-64b09cfc96b5'  # Bruno Fernandes (PELANGGAN)
    test_worker_id = 'df6e4bf7-ad28-4444-aefe-31a4d00c0d7b'  # Lisandro Martinez (PEKERJA)
    
    # Let's simulate switching between user and worker view
    is_worker_view = request.GET.get('view', 'user') == 'worker'
    current_user_id = test_worker_id if is_worker_view else test_user_id

    try:
        with connection.cursor() as cursor:
            # Get subcategory details
            cursor.execute("""
                SELECT sj.nama_subkategori, sj.deskripsi, kj.nama_kategori
                FROM SIJARTA.SUBKATEGORI_JASA sj
                JOIN SIJARTA.KATEGORI_JASA kj ON sj.id_kategori_jasa = kj.id_kategori_jasa
                WHERE sj.id_subkategori = %s
            """, [subcategory_id])
            
            subcategory_basic = cursor.fetchone()
            if not subcategory_basic:
                return render(request, 'service/error.html', {'message': 'Subcategory not found'})

            # Get service sessions
            cursor.execute("""
                SELECT sesi, harga
                FROM SIJARTA.SESI_LAYANAN
                WHERE id_subkategori = %s
                ORDER BY sesi
            """, [subcategory_id])
            
            service_sessions = [
                {
                    'name': f'Sesi {row[0]}',
                    'price': f'Rp {row[1]:,.2f}'
                }
                for row in cursor.fetchall()
            ]

            # Get workers for this subcategory
            cursor.execute("""
                SELECT DISTINCT p.id_user, u.nama, p.rating, p.jml_pesanan_selesai
                FROM SIJARTA.PEKERJA p
                JOIN SIJARTA.USERS u ON p.id_user = u.id_user
                JOIN SIJARTA.PEKERJA_KATEGORI_JASA pkj ON p.id_user = pkj.id_pekerja
                JOIN SIJARTA.SUBKATEGORI_JASA sj ON pkj.id_kategori_jasa = sj.id_kategori_jasa
                WHERE sj.id_subkategori = %s
            """, [subcategory_id])
            
            workers = [
                {
                    'id': row[0],
                    'name': row[1],
                    'rating': row[2],
                    'completed_orders': row[3]
                }
                for row in cursor.fetchall()
            ]

            # Get testimonials
            cursor.execute("""
                SELECT 
                    u.nama as user_name,
                    t.tgl as date,
                    t.teks as text,
                    w.nama as worker_name,
                    t.rating
                FROM SIJARTA.TESTIMONI t
                JOIN SIJARTA.TR_PEMESANAN_JASA tj ON t.id_tr_pemesanan_jasa = tj.id_tr_pemesanan_jasa
                JOIN SIJARTA.USERS u ON tj.id_pelanggan = u.id_user
                JOIN SIJARTA.USERS w ON tj.id_pekerja = w.id_user
                WHERE tj.id_subkategori = %s
                ORDER BY t.tgl DESC
                LIMIT 10
            """, [subcategory_id])

            testimonials = [
                {
                    'user_name': row[0],
                    'date': row[1].strftime('%Y-%m-%d'),
                    'text': row[2],
                    'worker_name': row[3],
                    'rating': row[4]
                }
                for row in cursor.fetchall()
            ]

            # Add query to get payment methods
            cursor.execute("""
                SELECT id_metode_bayar, nama
                FROM SIJARTA.METODE_BAYAR
                ORDER BY nama
            """)
            
            payment_methods = [
                {
                    'id': row[0],
                    'name': row[1]
                }
                for row in cursor.fetchall()
            ]

            # For worker view: check if worker has joined this category
            is_joined = False
            if is_worker_view:
                cursor.execute("""
                    SELECT 1
                    FROM SIJARTA.PEKERJA_KATEGORI_JASA pkj
                    JOIN SIJARTA.SUBKATEGORI_JASA sj ON pkj.id_kategori_jasa = sj.id_kategori_jasa
                    WHERE pkj.id_pekerja = %s AND sj.id_subkategori = %s
                """, [current_user_id, subcategory_id])
                is_joined = bool(cursor.fetchone())

            # Compile all data
            subcategory_data = {
                'name': subcategory_basic[0],
                'description': subcategory_basic[1],
                'category': subcategory_basic[2],
                'service_sessions': service_sessions,
                'workers': workers,
                'testimonials': testimonials,
                'is_joined': is_joined
            }

            template = 'service/subcategory_detail.html'
            return render(request, template, {
                'subcategory': subcategory_data,
                'is_worker_view': is_worker_view,
                'payment_methods': payment_methods
            })

    except Exception as e:
        print(f"Database Error: {str(e)}")
        return render(request, 'service/error.html', {'error': str(e)})

from django.http import JsonResponse

def validate_discount(request):
    discount_code = request.GET.get('code')
    amount = float(request.GET.get('amount', 0))
    
    try:
        with connection.cursor() as cursor:
            # Check if discount exists and meets minimum transaction requirement
            cursor.execute("""
                SELECT potongan, min_tr_pemesanan
                FROM SIJARTA.DISKON
                WHERE kode = %s
            """, [discount_code])
            
            result = cursor.fetchone()
            
            if result:
                discount_amount, min_transaction = result
                
                if amount >= min_transaction:
                    return JsonResponse({
                        'valid': True,
                        'discount_amount': float(discount_amount),
                        'message': 'Diskon berhasil diterapkan'
                    })
                else:
                    return JsonResponse({
                        'valid': False,
                        'message': f'Minimum transaksi Rp {min_transaction:,.2f}'
                    })
            else:
                return JsonResponse({
                    'valid': False,
                    'message': 'Kode diskon tidak valid'
                })
                
    except Exception as e:
        return JsonResponse({
            'valid': False,
            'message': 'Terjadi kesalahan saat memvalidasi diskon'
        })

def view_orders(request, user_id):
    try:
        with connection.cursor() as cursor:
            # Verify if the user exists and is a PELANGGAN
            cursor.execute("""
                SELECT 1
                FROM SIJARTA.PELANGGAN p
                WHERE p.id_user = %s
            """, [user_id])
            
            if not cursor.fetchone():
                return render(request, 'service/error.html', {
                    'message': 'User tidak ditemukan atau bukan pelanggan'
                })

            # Get all subcategories for filter
            cursor.execute("""
                SELECT DISTINCT sj.id_subkategori, sj.nama_subkategori
                FROM SIJARTA.SUBKATEGORI_JASA sj
                JOIN SIJARTA.TR_PEMESANAN_JASA tpj ON sj.id_subkategori = tpj.id_subkategori
                WHERE tpj.id_pelanggan = %s
                ORDER BY sj.nama_subkategori
            """, [user_id])
            
            subcategories = [
                {'id': row[0], 'name': row[1]}
                for row in cursor.fetchall()
            ]

            # Get all possible status options
            cursor.execute("""
                SELECT status 
                FROM SIJARTA.STATUS_PESANAN
                ORDER BY status
            """)
            status_options = [row[0] for row in cursor.fetchall()]

            # Get user's orders with their latest status
            cursor.execute("""
                WITH LatestStatus AS (
                    SELECT 
                        tps.id_tr_pemesanan_jasa,
                        sp.status,
                        ROW_NUMBER() OVER (PARTITION BY tps.id_tr_pemesanan_jasa ORDER BY tps.tgl_waktu DESC) as rn
                    FROM SIJARTA.TR_PEMESANAN_STATUS tps
                    JOIN SIJARTA.STATUS_PESANAN sp ON tps.id_status = sp.id_status
                )
                SELECT 
                    tpj.id_tr_pemesanan_jasa,
                    sj.nama_subkategori,
                    CONCAT('Sesi ', sl.sesi) as service_session,
                    CONCAT('Rp ', TO_CHAR(tpj.total_biaya, 'FM999,999,999.00')) as price,
                    u.nama as worker_name,
                    ls.status,
                    CASE WHEN t.id_tr_pemesanan_jasa IS NOT NULL THEN true ELSE false END as has_testimonial
                FROM SIJARTA.TR_PEMESANAN_JASA tpj
                JOIN SIJARTA.SUBKATEGORI_JASA sj ON tpj.id_subkategori = sj.id_subkategori
                JOIN SIJARTA.SESI_LAYANAN sl ON tpj.id_subkategori = sl.id_subkategori AND tpj.sesi = sl.sesi
                JOIN SIJARTA.PEKERJA p ON tpj.id_pekerja = p.id_user
                JOIN SIJARTA.USERS u ON p.id_user = u.id_user
                LEFT JOIN SIJARTA.TESTIMONI t ON tpj.id_tr_pemesanan_jasa = t.id_tr_pemesanan_jasa
                JOIN LatestStatus ls ON tpj.id_tr_pemesanan_jasa = ls.id_tr_pemesanan_jasa
                WHERE tpj.id_pelanggan = %s AND ls.rn = 1
                ORDER BY tpj.tgl_pemesanan DESC
            """, [user_id])

            orders = [
                {
                    'id': row[0],
                    'subcategory': row[1],
                    'service_session': row[2],
                    'price': row[3],
                    'worker_name': row[4],
                    'status': row[5],
                    'has_testimonial': row[6]
                }
                for row in cursor.fetchall()
            ]

            orders_data = {
                'subcategories': subcategories,
                'status_options': status_options,
                'orders': orders
            }

            return render(request, 'service/view_orders.html', {'data': orders_data})

    except Exception as e:
        print(f"Database Error: {str(e)}")
        return render(request, 'service/error.html', {'error': str(e)})
    
from django.http import JsonResponse
from datetime import date

def submit_testimonial(request):
    if request.method != 'POST':
        return JsonResponse({'success': False, 'message': 'Invalid request method'})
    
    try:
        order_id = request.POST.get('order_id')
        rating = request.POST.get('rating')
        text = request.POST.get('text')

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO SIJARTA.TESTIMONI (id_tr_pemesanan_jasa, tgl, teks, rating)
                VALUES (%s, %s, %s, %s)
            """, [order_id, date.today(), text, rating])

            return JsonResponse({
                'success': True,
                'message': 'Testimoni berhasil disimpan'
            })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': str(e)
        })

def cancel_order(request):
    if request.method != 'POST':
        return JsonResponse({'success': False, 'message': 'Invalid request method'})
    
    try:
        order_id = request.POST.get('order_id')

        with connection.cursor() as cursor:
            # Get cancel status ID
            cursor.execute("""
                SELECT id_status 
                FROM SIJARTA.STATUS_PESANAN 
                WHERE status = 'Pesanan dibatalkan'
            """)
            cancel_status_id = cursor.fetchone()[0]

            # Add cancel status to order
            cursor.execute("""
                INSERT INTO SIJARTA.TR_PEMESANAN_STATUS (id_tr_pemesanan_jasa, id_status, tgl_waktu)
                VALUES (%s, %s, CURRENT_TIMESTAMP)
            """, [order_id, cancel_status_id])

            return JsonResponse({
                'success': True,
                'message': 'Pesanan berhasil dibatalkan'
            })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': str(e)
        })
    

from django.http import JsonResponse
import uuid
from datetime import datetime, date

def submit_order(request):
    if request.method != 'POST':
        return JsonResponse({'success': False, 'message': 'Invalid request method'})
    
    try:
        # Extract data from request
        data = request.POST
        order_id = str(uuid.uuid4())
        order_date = data.get('order_date')
        total_cost = float(data.get('total_cost'))
        customer_id = data.get('customer_id')  # You'll need to get this from your auth system
        subcategory_id = data.get('subcategory_id')
        session = int(data.get('session'))
        discount_code = data.get('discount_code') or None
        payment_method_id = data.get('payment_method_id')

        with connection.cursor() as cursor:
            # Insert order into TR_PEMESANAN_JASA
            cursor.execute("""
                INSERT INTO SIJARTA.TR_PEMESANAN_JASA (
                    id_tr_pemesanan_jasa, tgl_pemesanan, tgl_pekerjaan, 
                    waktu_pekerjaan, total_biaya, id_pelanggan, id_pekerja,
                    id_subkategori, sesi, id_diskon, id_metode_bayar
                ) VALUES (
                    %s, %s, NULL, NULL, %s, %s, NULL, %s, %s, %s, %s
                )
            """, [
                order_id, order_date, total_cost,
                customer_id, subcategory_id, session,
                discount_code, payment_method_id
            ])

            # Get the ID for "Menunggu Pembayaran" status
            cursor.execute("""
                SELECT id_status 
                FROM SIJARTA.STATUS_PESANAN 
                WHERE status = 'Menunggu Pembayaran'
            """)
            waiting_payment_status_id = cursor.fetchone()[0]

            # Insert initial status
            cursor.execute("""
                INSERT INTO SIJARTA.TR_PEMESANAN_STATUS (
                    id_tr_pemesanan_jasa, id_status, tgl_waktu
                ) VALUES (%s, %s, %s)
            """, [order_id, waiting_payment_status_id, datetime.now()])

            return JsonResponse({
                'success': True,
                'message': 'Pesanan berhasil dibuat',
                'order_id': order_id
            })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': f'Error creating order: {str(e)}'
        })

def worker_profile(request):
    worker_data = {
        'name': 'John Doe',
        'rating': 4.8,  # Out of 5, will be multiplied by 2 for /10 rating
        'completed_orders': 45,
        'phone': '+62 812-3456-7890',
        'birth_date': '1990/05/15',
        'address': 'Jl. Contoh No. 123, Jakarta Selatan',
        'profile_image': None  # In a real implementation, this would be an image URL
    }
    return render(request, 'service/worker_profile.html', {'worker': worker_data})


from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection

@csrf_exempt
def delete_testimonial(request):
    if request.method == 'POST':
        # Get the transaction ID (order ID) from the POST request
        order_id = request.POST.get('order_id')

        if not order_id:
            return JsonResponse({'success': False, 'message': 'Order ID is required'})

        # Execute the query to delete the testimonial based on the order ID
        with connection.cursor() as cursor:
            cursor.execute("""
                DELETE FROM TESTIMONI
                WHERE id_tr_pemesanan_jasa = %s
            """, [order_id])
        
        # Check if the delete operation was successful
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT * FROM TESTIMONI
                WHERE id_tr_pemesanan_jasa = %s
            """, [order_id])
            testimonial = cursor.fetchone()
        
        # If no testimonial found, return success
        if not testimonial:
            return JsonResponse({'success': True, 'message': 'Testimonial deleted successfully'})
        
        return JsonResponse({'success': False, 'message': 'Error deleting testimonial'})

    return JsonResponse({'success': False, 'message': 'Invalid request method'})
