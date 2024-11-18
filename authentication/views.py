from django.shortcuts import render

# Create your views here.
def login_user(request):
    context = {
        'user': request.user,
    }
    return render(request, 'login.html', context)

def register(request):
    context = {
        'user': request.user,
    }
    return render(request, 'register.html', context)