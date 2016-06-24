#!/bin/bash

set -e

cd /app

. /setup/python_version.sh

# Locate Django settings

DJANGO_SETTINGS_MODULE=$(sudo -u www-data -E PYTHONPATH=/app/src $python -c 'import manage, os; print(os.getenv("DJANGO_SETTINGS_MODULE", ""))')
if [ -z "$DJANGO_SETTINGS_MODULE" ]; then
	>&2 echo "src/manage.py must set environment variable DJANGO_SETTINGS_MODULE"
	exit 1
fi
DJANGO_SETTINGS_DIR=/app/src/$(echo -ne $DJANGO_SETTINGS_MODULE | sed -re 's/[^\.]+$//' | sed -e 's/\./\//g')
echo "Found Django settings module '$DJANGO_SETTINGS_MODULE' at $DJANGO_SETTINGS_DIR"

# Put Docker settings

if [ "${DJANGO_DOCKER_SETTINGS-y}" == "y" ]; then
	DJANGO_DOCKER_SETTINGS_FILE=${DJANGO_DOCKER_SETTINGS_FILE:-docker_settings.py}
else
	DJANGO_DOCKER_SETTINGS_FILE=""
fi
if [ -n "$DJANGO_DOCKER_SETTINGS_FILE" ]; then
	DJANGO_DOCKER_SETTINGS_PATH="${DJANGO_SETTINGS_DIR}${DJANGO_DOCKER_SETTINGS_FILE}"
	if [ ! -f "$DJANGO_DOCKER_SETTINGS_PATH" ]; then
		echo "Adding $DJANGO_DOCKER_SETTINGS_PATH"
		ln -s /setup/django/docker_settings.py "$DJANGO_DOCKER_SETTINGS_PATH"
	fi
fi

# Setup local_settings.py

DJANGO_LOCAL_SETTINGS_FILE=${DJANGO_LOCAL_SETTINGS_FILE-$DJANGO_DOCKER_SETTINGS_FILE}
if [ -n "$DJANGO_LOCAL_SETTINGS_FILE" ]; then
	DJANGO_LOCAL_SETTINGS_DEST_FILE=${DJANGO_LOCAL_SETTINGS_DEST_FILE-local_settings.py}
	DJANGO_LOCAL_SETTINGS_DEST_PATH=${DJANGO_SETTINGS_DIR}${DJANGO_LOCAL_SETTINGS_DEST_FILE}
	if [ ! -f "$DJANGO_LOCAL_SETTINGS_DEST_PATH" ]; then
		echo "Linking $DJANGO_LOCAL_SETTINGS_DEST_PATH -> $DJANGO_LOCAL_SETTINGS_FILE"
		ln -s "$DJANGO_LOCAL_SETTINGS_FILE" "$DJANGO_LOCAL_SETTINGS_DEST_PATH"
	fi
fi

# setup_app.d

if [ -d setup_app.d ]; then
	run-parts --exit-on-error setup_app.d
fi

#
# At this point the Django app is fully configured. Hooray!
#

# Collect static on first run

if [ ! -f var/static ]; then
	mkdir -p var/static
	chown www-data var/static
	sudo -u www-data $python src/manage.py collectstatic --link --noinput
fi

# Migrate database

sudo -u www-data -E $python src/manage.py migrate --noinput

# entrypoint.d

if [ -d entrypoint.d ]; then
	run-parts --exit-on-error entrypoint.d
fi

# Create admin User if there ain't any users

if [ "${DJANGO_ADMIN_CREATE-y}" == "y" ]; then
	sudo -u www-data -E PYTHONPATH=/app/src $python /setup/django/create_admin.py
fi

# Configure wsgi

WSGI_APPLICATION=$(cd src; $python -c 'import manage, django; from django.conf import settings; print(settings.WSGI_APPLICATION or "")')
if [ -z "$WSGI_APPLICATION" ]; then
	>&2 echo "Django settings module at '$DJANGO_SETTINGS_MODULE' must define WSGI_APPLICATION"
	exit 1
fi
WSGI_APPLICATION_COLON=$(echo -ne $WSGI_APPLICATION | sed -re 's/\.([^\.]+)$/:\1/')
sed -i -e "s/^module=.*/module=${WSGI_APPLICATION_COLON}/" /etc/uwsgi/apps-enabled/app.ini
