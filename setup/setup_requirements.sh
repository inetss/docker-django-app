#!/bin/bash

set -e

cd /requirements

. /setup/python_version.sh

APT_PACKAGES=$(cat requirements.txt |grep '^# apt: '| sed -re 's/.*://')
if [ ! -z "$APT_PACKAGES" ]; then
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y $APT_PACKAGES
	rm -rf /var/lib/apt/lists/*
fi

if [ ! -d requirements.d ]; then
	# Dockerfile: COPY requirements.* pulls everything from requirements.d and discards the actual directory, restore it
	# Rockerfile: not needed, will be skipped (see https://github.com/grammarly/rocker/issues/103)
	mkdir requirements.d
	find . -type f -executable -depth 1 -exec mv "{}" requirements.d \;
fi
run-parts --exit-on-error requirements.d

pip=$($python -c 'import sys; print("pip{0}".format(sys.version_info[0]))')
$pip install --disable-pip-version-check --no-cache-dir -r requirements.txt

UWSGI_PLUGIN=$($python -c 'import sys; print("python{0}{1}".format(*sys.version_info[0:2]))')
sed -i -e "s/^plugins=.*/plugins=$UWSGI_PLUGIN/" /etc/uwsgi/apps-enabled/app.ini
