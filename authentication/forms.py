# forms.py
from django import forms

class PenggunaForm(forms.Form):
    nama = forms.CharField(max_length=100, widget=forms.TextInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    password = forms.CharField(widget=forms.PasswordInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    gender = forms.ChoiceField(choices=[('L', 'Laki-Laki'), ('P', 'Perempuan')],
                               widget=forms.RadioSelect(attrs={'class': 'form-radio text-blue-500'}))
    nohp = forms.CharField(max_length=15, widget=forms.TextInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    tanggal_lahir = forms.DateField(widget=forms.DateInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none', 'type': 'date'}))
    alamat = forms.CharField(widget=forms.Textarea(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))

class PekerjaForm(forms.Form):
    nama = forms.CharField(max_length=100, widget=forms.TextInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    password = forms.CharField(widget=forms.PasswordInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    gender = forms.ChoiceField(choices=[('L', 'Laki-Laki'), ('P', 'Perempuan')],
                               widget=forms.RadioSelect(attrs={'class': 'form-radio text-blue-500'}))
    nohp = forms.CharField(max_length=15, widget=forms.TextInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    tanggal_lahir = forms.DateField(widget=forms.DateInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none', 'type': 'date'}))
    alamat = forms.CharField(widget=forms.Textarea(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    bank = forms.ChoiceField(choices=[('gopay', 'GoPay'), ('ovo', 'OVO'), ('bca', 'Virtual Account BCA'),
                                      ('bni', 'Virtual Account BNI'), ('mandiri', 'Virtual Account Mandiri')],
                             widget=forms.Select(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    no_rekening = forms.CharField(max_length=20, widget=forms.TextInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    npwp = forms.CharField(max_length=20, widget=forms.TextInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
    foto = forms.URLField(widget=forms.URLInput(attrs={'class': 'w-full px-4 py-2 mt-1 bg-gray-700 text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none'}))
