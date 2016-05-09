#!/bin/bash

ln -s /setup/supervisor/app.conf /etc/supervisor/conf.d/
ln -s /setup/uwsgi/app.ini /etc/uwsgi/apps-enabled/
ln -sf /setup/nginx/default /etc/nginx/sites-enabled/
ln -s /setup/entrypoint.sh /
