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

# @login_required(login_url='/auth/login/')
def show_discount(request):
    context = {
        'user': request.user,
    }

    return render(request, "discount.html", context)