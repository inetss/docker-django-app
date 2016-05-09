#!/bin/bash

set -e

echoerr() { printf "%s\n" "$*" >&2; }

cd /app/src

DJANGO_SETTINGS_MODULE=$($python -c 'import manage, os; print(os.getenv("DJANGO_SETTINGS_MODULE"))')
if [ -z "$DJANGO_SETTINGS_MODULE" ]; then
	echoerr "src/manage.py should set environment variable DJANGO_SETTINGS_MODULE"
	exit 1
fi

mkdir -p /app/var/{media,static}
chown -R www-data /app/var/{media,static}

ln -s settings_docker.py $(echo -ne $DJANGO_SETTINGS_MODULE | sed -re 's/[^\.]+$//' | sed -e 's/\./\//g')local_settings.py
sudo -u www-data $python manage.py collectstatic --link --noinput
chown -R root /app/var/static

WSGI_APPLICATION=$($python -c 'import manage, django; from django.conf import settings; print(getattr(settings, "WSGI_APPLICATION", ""))')
if [ -z "$WSGI_APPLICATION" ]; then
	echoerr "$DJANGO_SETTINGS_MODULE should define WSGI_APPLICATION"
	exit 1
fi
sed -i -e "s/module=.*/module=$(echo -ne $WSGI_APPLICATION | sed -re 's/\.([^\.]+)$/:\1/')/" /etc/uwsgi/apps-enabled/app.ini
