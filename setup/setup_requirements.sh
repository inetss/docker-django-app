#!/bin/bash

set -e

. /setup/python_version.sh

APT_PACKAGES=$(cat /app/requirements.txt |grep '# apt'| sed -re 's/.*://')
if [ ! -z "$APT_PACKAGES" ]; then
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y $APT_PACKAGES
	rm -rf /var/lib/apt/lists/*
fi

pip${PYTHON_SUFFIX} install --disable-pip-version-check --no-cache-dir -r /app/requirements.txt

sed -i -e "s/^plugins=.*/plugins=$python/" /etc/uwsgi/apps-enabled/app.ini
