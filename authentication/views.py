import uuid
import psycopg2
from django.db import connection
from django.conf import settings
from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.contrib.auth.forms import AuthenticationForm, UserCreationForm
from django.contrib.auth.hashers import make_password, check_password
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.urls import reverse
from .forms import PenggunaForm, PekerjaForm

def login_user(request):
    if request.method == 'POST':
        phone = request.POST.get('phone')  # Assuming the login form has a 'phone' field
        password = request.POST.get('password')  # Assuming the login form has a 'password' field

        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT id_user, nama, jenis_kelamin, no_hp, pwd, tgl_lahir, alamat, saldomypay FROM USERS WHERE no_hp = %s", (phone,))
                user = cursor.fetchone()

                if user:
                    # Verify the password
                    if check_password(password, user[4]):
                        # Create a session for the user
                        request.session['id_user'] = str(user[0])  # Store the user's ID in the session
                        request.session['nama'] = str(user[1])
                        request.session['gender'] = str(user[2])
                        request.session['no_hp'] = str(user[3])
                        request.session['tgl_lahir'] = str(user[5])
                        request.session['alamat'] = str(user[6])
                        request.session['saldo'] = str(user[7])
                        
                        cursor.execute("""
                            SELECT COUNT(*) FROM PEKERJA WHERE id_user = %s;
                            """, [user[0]])
                        if cursor.fetchone()[0] > 0:
                            cursor.execute("""
                                SELECT nama_bank, nomor_rekening, npwp, link_foto, rating, jml_pesanan_selesai FROM PELANGGAN WHERE id_user = %s;""", [user[0]])
                            pekerja = cursor.fetchone()
                            request.session['user_role'] = 'pekerja'
                            request.session['nama_bank'] = pekerja[0]
                            request.session['nomor_rekening'] = pekerja[1]
                            request.session['npwp'] = pekerja[2]
                            request.session['link_foto'] = pekerja[3]
                            request.session['rating'] = pekerja[4]
                            request.session['jml_pesanan'] = pekerja[5]
                            
                        cursor.execute("""
                            SELECT COUNT(*) FROM PELANGGAN WHERE id_user = %s;
                            """, [user[0]])
                        if cursor.fetchone()[0] > 0:
                            cursor.execute("SELECT level FROM PELANGGAN WHERE id_user = %s;", [user[0]])
                            pelanggan = cursor.fetchone()
                            request.session['user_role'] = 'pelanggan'
                            request.session['level'] = str(pelanggan[0])
                            

                        print("User role set:", request.session['user_role'])  # Debug log
                        return redirect('service:homepage')  # Redirect to the desired page
                    
                    else:
                        messages.error(request, 'Invalid credentials')
                else:
                    messages.error(request, 'User not found')

        except psycopg2.Error as e:
            print(e)
            messages.error(request, f'Database error: {str(e)}')

    # If GET or invalid POST, render the login form
    return render(request, 'login.html')

def register(request):
    pengguna_form = PenggunaForm()
    pekerja_form = PekerjaForm()

    if request.method == "POST":
        try:
            # Generate a unique id_user
            id_user = str(uuid.uuid4())

            if 'role-pengguna' in request.POST:
                pengguna_form = PenggunaForm(request.POST)
                if pengguna_form.is_valid():
                    # Hash the password
                    hashed_password = make_password(pengguna_form.cleaned_data['password'])

                    # Insert into the USERS table
                    with connection.cursor() as cursor:
                        cursor.execute("""
                            INSERT INTO users (id_user, nama, jenis_kelamin, no_hp, pwd, tgl_lahir, alamat, saldomypay)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        """, (
                            id_user,
                            pengguna_form.cleaned_data['nama'],
                            pengguna_form.cleaned_data['gender'],
                            pengguna_form.cleaned_data['nohp'],
                            hashed_password,
                            pengguna_form.cleaned_data['tanggal_lahir'],
                            pengguna_form.cleaned_data['alamat'],
                            0  # Initial saldomypay value
                        ))

                        # Insert into PELANGGAN table
                        cursor.execute("""
                            INSERT INTO PELANGGAN (id_user, level)
                            VALUES (%s, %s)
                        """, (id_user, "1"))  # Default level for new users
                        
                    messages.success(request, 'Pengguna registration successful')
                    return redirect('authentication:login')

            elif 'role-pekerja' in request.POST:
                pekerja_form = PekerjaForm(request.POST)
                if pekerja_form.is_valid():
                    # Hash the password
                    hashed_password = make_password(pekerja_form.cleaned_data['password'])

                    # Insert into the USERS table
                    with connection.cursor() as cursor:
                        cursor.execute("""
                            INSERT INTO USERS (id_user, nama, jenis_kelamin, no_hp, pwd, tgl_lahir, alamat, saldomypay)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        """, (
                            id_user,
                            pekerja_form.cleaned_data['nama'],
                            pekerja_form.cleaned_data['gender'],  # 'L' or 'P'
                            pekerja_form.cleaned_data['nohp'],
                            hashed_password,
                            pekerja_form.cleaned_data['tanggal_lahir'],
                            pekerja_form.cleaned_data['alamat'],
                            0  # Initial saldomypay value
                        ))

                        # Insert into PEKERJA table
                        cursor.execute("""
                            INSERT INTO PEKERJA (id_user, nama_bank, nomor_rekening, npwp, link_foto, rating, jml_pesanan_selesai)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (
                            id_user,
                            pekerja_form.cleaned_data['bank'],
                            pekerja_form.cleaned_data['no_rekening'],
                            pekerja_form.cleaned_data['npwp'],
                            pekerja_form.cleaned_data['foto'],
                            0,  # Initial rating
                            0   # Initial jml_pesanan_selesai
                        ))
                        
                    messages.success(request, 'Pekerja registration successful')
                    return redirect('authentication:login')

        except psycopg2.Error as e:
            print(e)
            messages.error(request, f'Database error: {str(e)}')

    return render(request, 'register.html', {
        'pengguna_form': pengguna_form,
        'pekerja_form': pekerja_form
    })

def logout_user(request):
    request.session.flush()
    return redirect('authentication:login')