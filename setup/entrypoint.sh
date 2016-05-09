#!/bin/bash

. /setup/python_version.sh

cd /app/src
sudo -u www-data -E $python manage.py migrate --noinput
[ ! -z "$DJANGO_ADMIN_CREATE" ] && sudo -u www-data -E $python << EOF
import django, manage, os
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.exists():
	admin = User(is_staff=True, is_superuser=True, **{User.USERNAME_FIELD: os.getenv("DJANGO_ADMIN_USERNAME", "admin")})
	admin.set_password(os.getenv("DJANGO_ADMIN_PASSWORD", "admin"))
	admin.save()
EOF

supervisord -c /etc/supervisor/supervisord.conf -n
