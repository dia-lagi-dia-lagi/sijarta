from django.shortcuts import render

def homepage(request):
    # For now, using hardcoded data
    categories = [
        {
            'name': 'Kategori Jasa 1',
            'subcategories': [
                'Subkategori Jasa 1',
                'Subkategori Jasa 2',
                'Subkategori Jasa 3',
            ]
        },
        {
            'name': 'Kategori Jasa 2',
            'subcategories': [
                'Subkategori Jasa 1',
                'Subkategori Jasa 2',
                'Subkategori Jasa 3',
            ]
        },
        {
            'name': 'Kategori Jasa 3',
            'subcategories': [
                'Subkategori Jasa 1',
                'Subkategori Jasa 2',
                'Subkategori Jasa 3',
            ]
        },
    ]
    
    return render(request, 'service/homepage.html', {'categories': categories})

def subcategory_detail_pengguna(request):
    # Hardcoded data for now
    subcategory_data = {
        'name': 'Subkategori Jasa 1',
        'category': 'Kategori Jasa 1',
        'description': 'Deskripsi lengkap tentang subkategori jasa ini dan layanan yang ditawarkan.',
        'service_sessions': [
            {
                'name': 'Sesi Layanan Basic',
                'price': 'Rp 150.000',
            },
            {
                'name': 'Sesi Layanan Premium',
                'price': 'Rp 300.000',
            }
        ],
        'workers': [
            {'id': 1, 'name': 'Nama Pekerja 1'},
            {'id': 2, 'name': 'Nama Pekerja 2'},
            {'id': 3, 'name': 'Nama Pekerja 3'},
            {'id': 4, 'name': 'Nama Pekerja 4'},
        ],
        'testimonials': [
            {
                'user_name': 'Nama Pengguna 1',
                'date': '2024-01-15',
                'text': 'Pelayanan sangat memuaskan dan profesional',
                'worker_name': 'Nama Pekerja 1',
                'rating': 5
            },
            {
                'user_name': 'Nama Pengguna 2',
                'date': '2024-01-10',
                'text': 'Hasil kerja bagus dan tepat waktu',
                'worker_name': 'Nama Pekerja 2',
                'rating': 4
            }
        ]
    }
    return render(request, 'service/subcategory_detail_pengguna.html', {'subcategory': subcategory_data})

def subcategory_detail_pekerja(request):
    # Hardcoded data for worker view
    subcategory_data = {
        'name': 'Subkategori Jasa 1',
        'category': 'Kategori Jasa 1',
        'description': 'Deskripsi lengkap tentang subkategori jasa ini dan layanan yang ditawarkan.',
        'service_sessions': [
            {
                'name': 'Sesi Layanan Basic',
                'price': 'Rp 150.000',
            },
            {
                'name': 'Sesi Layanan Premium',
                'price': 'Rp 300.000',
            }
        ],
        'workers': [
            {'id': 1, 'name': 'Nama Pekerja 1'},
            {'id': 2, 'name': 'Nama Pekerja 2'},
            {'id': 3, 'name': 'Nama Pekerja 3'},
            {'id': 4, 'name': 'Nama Pekerja 4'},
        ],
        'testimonials': [
            {
                'user_name': 'Nama Pengguna 1',
                'date': '2024-01-15',
                'text': 'Pelayanan sangat memuaskan dan profesional',
                'worker_name': 'Nama Pekerja 1',
                'rating': 5
            },
            {
                'user_name': 'Nama Pengguna 2',
                'date': '2024-01-10',
                'text': 'Hasil kerja bagus dan tepat waktu',
                'worker_name': 'Nama Pekerja 2',
                'rating': 4
            }
        ],
        'is_joined': False  # Flag to determine if the worker has joined this category
    }
    return render(request, 'service/subcategory_detail_pekerja.html', {'subcategory': subcategory_data})

from django.shortcuts import render

def view_orders(request):
    # Hardcoded data for demonstration
    orders_data = {
        'subcategories': [
            {'id': 1, 'name': 'Subkategori Jasa 1'},
            {'id': 2, 'name': 'Subkategori Jasa 2'},
            {'id': 3, 'name': 'Subkategori Jasa 3'},
        ],
        'status_options': [
            'Menunggu Pembayaran',
            'Mencari Pekerja Terdekat',
            'Dalam Proses',
            'Pesanan Selesai'
        ],
        'orders': [
            {
                'id': 1,
                'subcategory': 'Subkategori Jasa 1',
                'service_session': 'Sesi Layanan Premium',
                'price': 'Rp 300.000',
                'worker_name': 'Nama Pekerja 1',
                'status': 'Menunggu Pembayaran',
                'has_testimonial': False
            },
            {
                'id': 2,
                'subcategory': 'Subkategori Jasa 2',
                'service_session': 'Sesi Layanan Basic',
                'price': 'Rp 150.000',
                'worker_name': 'Nama Pekerja 2',
                'status': 'Pesanan Selesai',
                'has_testimonial': False
            },
            {
                'id': 3,
                'subcategory': 'Subkategori Jasa 1',
                'service_session': 'Sesi Layanan Basic',
                'price': 'Rp 150.000',
                'worker_name': 'Nama Pekerja 3',
                'status': 'Mencari Pekerja Terdekat',
                'has_testimonial': False
            }
        ]
    }
    return render(request, 'service/view_orders.html', {'data': orders_data})

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

# def worker_profile(request, worker_id):
#     # This will be implemented later
#     return render(request, 'service/worker_profile.html')