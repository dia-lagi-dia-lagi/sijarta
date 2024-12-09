from django.shortcuts import render
from django.db import connection
from django.http import JsonResponse
from django.contrib.auth.decorators import login_required
import json
from decimal import Decimal
from datetime import datetime

# Create your views here.

def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

@login_required
def mypay_home(request):
    with connection.cursor() as cursor:
        # Get user's MyPay balance
        cursor.execute("""
            SELECT saldomypay, no_hp 
            FROM users 
            WHERE id_user = %s
        """, [request.user.id])
        user_data = dictfetchall(cursor)[0]
        
        # Get transaction history
        cursor.execute("""
            SELECT tm.nominal, tm.tgl, ktm.nama as kategori
            FROM tr_mypay tm
            JOIN kategori_tr_mypay ktm ON tm.id_kategori_tr_mypay = ktm.id_kategori_tr_mypay
            WHERE tm.id_user = %s
            ORDER BY tm.tgl DESC
            LIMIT 10
        """, [request.user.id])
        transactions = dictfetchall(cursor)
        
    context = {
        'saldo': user_data['saldomypay'],
        'no_hp': user_data['no_hp'],
        'transactions': transactions
    }
    return render(request, 'mypay_home.html', context)

@login_required
def transaksi_mypay(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        kategori = data.get('kategori')
        nominal = Decimal(data.get('nominal'))
        
        with connection.cursor() as cursor:
            try:
                # Start transaction
                cursor.execute("BEGIN")
                
                # Check if user has sufficient balance for withdrawals/transfers
                if kategori in ['Withdrawal', 'Transfer', 'Pembayaran Jasa']:
                    cursor.execute("""
                        SELECT saldomypay 
                        FROM users 
                        WHERE id_user = %s
                    """, [request.user.id])
                    current_balance = cursor.fetchone()[0]
                    if current_balance < nominal:
                        raise Exception("Saldo tidak mencukupi")

                if kategori == 'Transfer':
                    # Verify target phone number exists
                    no_hp_tujuan = data.get('no_hp_tujuan')
                    cursor.execute("""
                        SELECT id_user 
                        FROM users 
                        WHERE no_hp = %s
                    """, [no_hp_tujuan])
                    target_user = cursor.fetchone()
                    if not target_user:
                        raise Exception("Nomor HP tujuan tidak ditemukan")
                    
                    # Update target user's balance
                    cursor.execute("""
                        UPDATE users 
                        SET saldomypay = saldomypay + %s 
                        WHERE no_hp = %s
                    """, [nominal, no_hp_tujuan])

                elif kategori == 'Pembayaran Jasa':
                    # Verify the order exists and is unpaid
                    id_pemesanan = data.get('id_pemesanan')
                    cursor.execute("""
                        SELECT total_biaya 
                        FROM tr_pemesanan_jasa 
                        WHERE id_tr_pemesanan_jasa = %s 
                        AND id_pelanggan = %s
                    """, [id_pemesanan, request.user.id])
                    order = cursor.fetchone()
                    if not order:
                        raise Exception("Pesanan tidak ditemukan")

                # Insert transaction record
                cursor.execute("""
                    INSERT INTO tr_mypay (id_tr_mypay, id_user, tgl, nominal, id_kategori_tr_mypay)
                    VALUES (uuid_generate_v4(), %s, CURRENT_DATE, %s, 
                        (SELECT id_kategori_tr_mypay FROM kategori_tr_mypay WHERE nama = %s))
                """, [request.user.id, nominal, kategori])
                
                # Update user balance
                if kategori == 'TopUp':
                    cursor.execute("""
                        UPDATE users 
                        SET saldomypay = saldomypay + %s 
                        WHERE id_user = %s
                    """, [nominal, request.user.id])
                else:
                    cursor.execute("""
                        UPDATE users 
                        SET saldomypay = saldomypay - %s 
                        WHERE id_user = %s
                    """, [nominal, request.user.id])
                
                cursor.execute("COMMIT")
                return JsonResponse({'status': 'success'})
            except Exception as e:
                cursor.execute("ROLLBACK")
                return JsonResponse({'status': 'error', 'message': str(e)})
    
    # GET request - show form
    with connection.cursor() as cursor:
        # Get user data
        cursor.execute("""
            SELECT nama, saldomypay 
            FROM users 
            WHERE id_user = %s
        """, [request.user.id])
        user_data = dictfetchall(cursor)[0]
        
        # Get pending orders for payment (if user is not a worker)
        pending_orders = []
        if not request.user.is_pekerja:
            cursor.execute("""
                SELECT tpj.id_tr_pemesanan_jasa, sj.nama_subkategori, tpj.total_biaya
                FROM tr_pemesanan_jasa tpj
                JOIN subkategori_jasa sj ON tpj.id_subkategori = sj.id_subkategori
                JOIN tr_pemesanan_status tps ON tpj.id_tr_pemesanan_jasa = tps.id_tr_pemesanan_jasa
                WHERE tpj.id_pelanggan = %s
                AND tps.id_status = (
                    SELECT id_status 
                    FROM status_pesanan 
                    WHERE status = 'Menunggu Pembayaran'
                )
            """, [request.user.id])
            pending_orders = dictfetchall(cursor)
        
    return render(request, 'transaksi_mypay.html', {
        'user_data': user_data,
        'pending_orders': pending_orders
    })

@login_required
def pekerjaan_jasa(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        order_id = data.get('order_id')
        
        with connection.cursor() as cursor:
            try:
                cursor.execute("BEGIN")
                
                # Update the order with worker's ID and work date
                work_date = datetime.now().date()
                cursor.execute("""
                    UPDATE tr_pemesanan_jasa 
                    SET id_pekerja = %s,
                        tgl_pekerjaan = %s,
                        waktu_pekerjaan = %s + INTERVAL '1 day' * sesi
                    WHERE id_tr_pemesanan_jasa = %s
                    """, [request.user.id, work_date, work_date, order_id])
                
                # Add new status "Menunggu Pekerja Berangkat"
                cursor.execute("""
                    INSERT INTO tr_pemesanan_status (id_tr_pemesanan_jasa, id_status, tgl_waktu)
                    VALUES (%s, 
                        (SELECT id_status FROM status_pesanan WHERE status = 'Menunggu Pekerja Berangkat'),
                        CURRENT_TIMESTAMP)
                    """, [order_id])
                
                cursor.execute("COMMIT")
                return JsonResponse({'status': 'success'})
            except Exception as e:
                cursor.execute("ROLLBACK")
                return JsonResponse({'status': 'error', 'message': str(e)})
    
    # GET request - show available jobs
    with connection.cursor() as cursor:
        # Get categories where the worker is registered
        cursor.execute("""
            SELECT DISTINCT kj.id_kategori_jasa, kj.nama_kategori
            FROM kategori_jasa kj
            JOIN pekerja_kategori_jasa pkj ON kj.id_kategori_jasa = pkj.id_kategori_jasa
            WHERE pkj.id_pekerja = %s
            """, [request.user.id])
        categories = dictfetchall(cursor)
        
        # Get all subcategories for these categories
        category_ids = [cat['id_kategori_jasa'] for cat in categories]
        placeholder = ','.join(['%s'] * len(category_ids))
        cursor.execute(f"""
            SELECT id_subkategori, nama_subkategori, id_kategori_jasa
            FROM subkategori_jasa
            WHERE id_kategori_jasa IN ({placeholder})
            """, category_ids)
        subcategories = dictfetchall(cursor)
        
        # Get available jobs (status "Mencari Pekerja Terdekat")
        cursor.execute(f"""
            SELECT 
                tpj.id_tr_pemesanan_jasa,
                tpj.tgl_pemesanan,
                tpj.total_biaya,
                sj.nama_subkategori,
                u.nama as nama_pelanggan,
                kj.nama_kategori,
                sl.sesi
            FROM tr_pemesanan_jasa tpj
            JOIN subkategori_jasa sj ON tpj.id_subkategori = sj.id_subkategori
            JOIN kategori_jasa kj ON sj.id_kategori_jasa = kj.id_kategori_jasa
            JOIN users u ON tpj.id_pelanggan = u.id_user
            JOIN sesi_layanan sl ON tpj.id_subkategori = sl.id_subkategori AND tpj.sesi = sl.sesi
            WHERE sj.id_kategori_jasa IN ({placeholder})
            AND EXISTS (
                SELECT 1 FROM tr_pemesanan_status tps
                WHERE tps.id_tr_pemesanan_jasa = tpj.id_tr_pemesanan_jasa
                AND tps.id_status = (
                    SELECT id_status FROM status_pesanan 
                    WHERE status = 'Mencari Pekerja Terdekat'
                )
            )
            """, category_ids)
        available_jobs = dictfetchall(cursor)
        
    context = {
        'categories': categories,
        'subcategories': subcategories,
        'available_jobs': available_jobs
    }
    return render(request, 'pekerjaan_jasa.html', context)

@login_required
def status_pekerjaan_jasa(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        job_id = data.get('job_id')
        new_status = data.get('new_status')
        
        with connection.cursor() as cursor:
            try:
                cursor.execute("BEGIN")
                
                # Verify that this job belongs to the worker
                cursor.execute("""
                    SELECT 1 
                    FROM tr_pemesanan_jasa 
                    WHERE id_tr_pemesanan_jasa = %s 
                    AND id_pekerja = %s
                """, [job_id, request.user.id])
                
                if not cursor.fetchone():
                    raise Exception("Pesanan tidak ditemukan atau bukan milik Anda")
                
                # Get current status
                cursor.execute("""
                    SELECT sp.status
                    FROM tr_pemesanan_status tps
                    JOIN status_pesanan sp ON tps.id_status = sp.id_status
                    WHERE tps.id_tr_pemesanan_jasa = %s
                    ORDER BY tps.tgl_waktu DESC
                    LIMIT 1
                """, [job_id])
                current_status = cursor.fetchone()[0]
                
                # Verify status transition is valid
                valid_transitions = {
                    'Menunggu Pekerja Berangkat': 'Pekerja tiba di lokasi',
                    'Pekerja tiba di lokasi': 'Pelayanan jasa sedang dilakukan',
                    'Pelayanan jasa sedang dilakukan': 'Pesanan selesai'
                }
                
                if current_status not in valid_transitions or valid_transitions[current_status] != new_status:
                    raise Exception("Status transition tidak valid")
                
                # Insert new status
                cursor.execute("""
                    INSERT INTO tr_pemesanan_status (id_tr_pemesanan_jasa, id_status, tgl_waktu)
                    VALUES (%s, 
                        (SELECT id_status FROM status_pesanan WHERE status = %s),
                        CURRENT_TIMESTAMP)
                """, [job_id, new_status])
                
                cursor.execute("COMMIT")
                return JsonResponse({'status': 'success'})
            except Exception as e:
                cursor.execute("ROLLBACK")
                return JsonResponse({'status': 'error', 'message': str(e)})
    
    # GET request - show current jobs and their statuses
    with connection.cursor() as cursor:
        # Get list of statuses for filter
        cursor.execute("SELECT status FROM status_pesanan ORDER BY id_status")
        status_list = [row[0] for row in cursor.fetchall()]
        
        # Get all jobs for this worker with their current status
        cursor.execute("""
            WITH LatestStatus AS (
                SELECT tps.id_tr_pemesanan_jasa, 
                       sp.status as current_status,
                       sp.id_status,
                       ROW_NUMBER() OVER (PARTITION BY tps.id_tr_pemesanan_jasa ORDER BY tps.tgl_waktu DESC) as rn
                FROM tr_pemesanan_status tps
                JOIN status_pesanan sp ON tps.id_status = sp.id_status
            )
            SELECT 
                tpj.id_tr_pemesanan_jasa,
                tpj.tgl_pemesanan,
                tpj.tgl_pekerjaan,
                tpj.waktu_pekerjaan,
                tpj.total_biaya,
                sj.nama_subkategori,
                u.nama as nama_pelanggan,
                ls.current_status
            FROM tr_pemesanan_jasa tpj
            JOIN subkategori_jasa sj ON tpj.id_subkategori = sj.id_subkategori
            JOIN users u ON tpj.id_pelanggan = u.id_user
            JOIN LatestStatus ls ON tpj.id_tr_pemesanan_jasa = ls.id_tr_pemesanan_jasa
            WHERE tpj.id_pekerja = %s
            AND ls.rn = 1
            ORDER BY tpj.tgl_pekerjaan DESC, tpj.waktu_pekerjaan DESC
        """, [request.user.id])
        jobs = dictfetchall(cursor)
        
    return render(request, 'status_pekerjaan_jasa.html', {
        'jobs': jobs,
        'status_list': status_list
    })