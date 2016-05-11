#!/bin/bash

if [ ! -f /app/var/installed.flag ]; then
	>&2 echo "/app/var/installed.flag not found, falling back to bash prompt"
	>&2 echo "Did you run this image instead of inheriting from it?"
	/bin/bash
	exit
fi

set -e

. /setup/setup_app.sh

supervisord -c /etc/supervisor/supervisord.conf -n
