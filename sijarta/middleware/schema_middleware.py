from django.db import connection

class SchemaMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Set the search_path for each request
        schema_name = 'sijarta'  # Replace with dynamic logic if needed
        with connection.cursor() as cursor:
            cursor.execute(f'SET search_path TO {schema_name};')
        
        response = self.get_response(request)
        return response
    
