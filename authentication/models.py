from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    # Define common fields for both roles
    ROLE_CHOICES = [
        ('pengguna', 'Pengguna'),
        ('pekerja', 'Pekerja'),
    ]
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='pengguna')
    gender = models.CharField(max_length=20, choices=[('Laki-Laki', 'Laki-Laki'), ('Perempuan', 'Perempuan')], null=True, blank=True)
    phone_number = models.CharField(max_length=15, null=True, blank=True)
    birth_date = models.DateField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)

    # Add fields specific to the 'pekerja' role
    bank_name = models.CharField(max_length=50, null=True, blank=True)
    account_number = models.CharField(max_length=50, null=True, blank=True)
    npwp = models.CharField(max_length=20, null=True, blank=True)
    photo_url = models.URLField(null=True, blank=True)

    def is_pengguna(self):
        return self.role == 'pengguna'

    def is_pekerja(self):
        return self.role == 'pekerja'

    def __str__(self):
        return self.username
