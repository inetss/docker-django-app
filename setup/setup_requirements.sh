#!/bin/bash

set -e

. /setup/python_version.sh

APT_PACKAGES=$(cat /app/requirements.txt |grep '^# apt: '| sed -re 's/.*://')
if [ ! -z "$APT_PACKAGES" ]; then
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y $APT_PACKAGES
	rm -rf /var/lib/apt/lists/*
fi

[ -x /app/requirements.sh ] && /app/requirements.sh

pip=$($python -c 'import sys; print("pip{0}".format(sys.version_info[0]))')
$pip install --disable-pip-version-check --no-cache-dir -r /app/requirements.txt

UWSGI_PLUGIN=$($python -c 'import sys; print("python{0}{1}".format(*sys.version_info[0:2]))')
sed -i -e "s/^plugins=.*/plugins=$UWSGI_PLUGIN/" /etc/uwsgi/apps-enabled/app.ini
