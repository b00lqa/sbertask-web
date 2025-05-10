from django.http import JsonResponse
from django.db import connections
from django.db.utils import OperationalError
from psycopg2 import OperationalError as PsycopgOperationalError

def health_check(request):
    try:
        db_conn = connections['default']
        db_conn.cursor()
        return JsonResponse(
            {
                "status": "healthy",
                "database": "connected"
            },
            status=200
        )
    except (OperationalError, PsycopgOperationalError):
        return JsonResponse(
            {
                "status": "unhealthy",
                "database": "disconnected"
            },
            status=503
        )