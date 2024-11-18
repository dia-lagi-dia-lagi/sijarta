from django.shortcuts import render

# Create your views here.

def mypay_home(request):
    return render(request, 'mypay_home.html')

def transaksi_mypay(request):
    return render(request, 'transaksi_mypay.html')

def pekerjaan_jasa(request):
    return render(request, 'pekerjaan_jasa.html')

def status_pekerjaan_jasa(request):
    return render(request, 'status_pekerjaan_jasa.html')