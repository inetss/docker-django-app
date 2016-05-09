#!/bin/bash

set -e

. /setup/python_version.sh

cd /app/src

DJANGO_SETTINGS_MODULE=$($python -c 'import manage, os; print(os.getenv("DJANGO_SETTINGS_MODULE", ""))')
if [ -z "$DJANGO_SETTINGS_MODULE" ]; then
	>&2 echo "src/manage.py must set environment variable DJANGO_SETTINGS_MODULE"
	exit 1
fi

mkdir -p /app/var/static
chown -R www-data /app/var/static
ln -s settings_docker.py $(echo -ne $DJANGO_SETTINGS_MODULE | sed -re 's/[^\.]+$//' | sed -e 's/\./\//g')local_settings.py
sudo -u www-data $python manage.py collectstatic --link --noinput
chown -R root /app/var/static

WSGI_APPLICATION=$($python -c 'import manage, django; from django.conf import settings; print(settings.WSGI_APPLICATION or "")')
if [ -z "$WSGI_APPLICATION" ]; then
	>&2 echo "Django settings module at '$DJANGO_SETTINGS_MODULE' must define WSGI_APPLICATION"
	exit 1
fi
sed -i -e "s/^module=.*/module=$(echo -ne $WSGI_APPLICATION | sed -re 's/\.([^\.]+)$/:\1/')/" /etc/uwsgi/apps-enabled/app.ini
