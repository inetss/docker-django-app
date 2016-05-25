# Introduction

This is a reusable Docker container to run a Django app with nginx and uwsgi.

Features:

* Universal Python 2.7, 3.4, 3.5
* Uses `requirements.txt` for Python
* Uses Ubuntu 16.04 packages for anything else
* nginx reverse proxy for `collectstatic` and media folders
* Links to Postgres and MySQL containers
* Initializes and migrates database; creates admin on first run

# TL;DR HOWTO

# Step 1: Setup

### Dockerfile

```
FROM inetss/django-app
```

### requirements.txt

```
# apt: libjpeg-dev libpq-dev
# python: python3.5
Django==1.9.5
psycopg2==2.6.1
...
```

### src/manage.py

```
#!/usr/bin/env python

import os
import sys

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "app.settings")

if __name__ == "__main__":
	from django.core.management import execute_from_command_line
	execute_from_command_line(sys.argv)
```

### src/app/settings.py

```
...
from .local_settings import *
```

### var/media

Point `MEDIA_ROOT` here.

### var/static

Point `STATICFILES_ROOT` here.

## Step 2: Build, run and test

```
$ docker build -t app .
$ docker run -d --name app-postgres -e POSTGRES_PASSWORD=secret postgres
$ docker run --rm -it --name app --link app-postgres:postgres -e DJANGO_DEBUG=1 -v $(pwd)/var/media:/app/var/media -p 8000:80 app
```

Then open <http://localhost:8000>

# Entrypoint customization

The following environment variables are accepted:

## `DJANGO_DOCKER_SETTINGS=y`

If set to "y", puts `settings_docker.py` helper near your `settings.py`

## `DJANGO_DOCKER_SETTINGS_FILE=settings_docker.py`

Overrides `settings_docker.py` file name (see `DJANGO_DOCKER_SETTINGS`)

## `DJANGO_LOCAL_SETTINGS_FILE=settings_docker.py`

Creates a symlink from that file to `local_settings.py`

The actual default is `DJANGO_DOCKER_SETTINGS_FILE`.

Ignored if `DJANGO_DOCKER_SETTINGS` is disabled.

## `DJANGO_LOCAL_SETTINGS_DEST_FILE=local_settings.py`

Creates a symlink from `settings_docker.py` to this file.

Ignored if `DJANGO_DOCKER_SETTINGS` is disabled, or if the file already exists.

## `DJANGO_ADMIN_CREATE=y`

If there is no users in the database, creates a default admin user. Supports custom `User` models.

## `DJANGO_ADMIN_USERNAME=admin`

## `DJANGO_ADMIN_PASSWORD=admin`

# Django settings customization

If Docker settings integration is not disabled by `DJANGO_DOCKER_SETTINGS=n`, the following environment variables are additionally accepted:

## `DJANGO_ALLOWED_HOSTS`

Comma-separated list that goes into Django `ALLOWED_HOSTS`.

## `DJANGO_DEBUG`

Set to anything non-empty to enable Django `DEBUG`.

## `MEMCACHED_PORT_11211_TCP_ADDR` and friends

Discovers a link to the official `memcached` Docker container and configures Django `CACHES`.

## `MEMCACHED_LOCATION`

Use [Django memcached location format](https://docs.djangoproject.com/en/1.9/topics/cache/#memcached) (e.g. `server:port`).

## `MYSQL_PORT_3306_TCP_ADDR` and friends

Discovers a link to the official `mysql` Docker container and configures Django `DATABASES`.

## `MYSQL_HOST`

## `MYSQL_PORT`

## `MYSQL_USER` or `MYSQL_USERNAME`

Defaults to `root`.

## `MYSQL_PASS` or `MYSQL_PASSWORD`

## `MYSQL_DB` or `MYSQL_DATABASE`

## `POSTGRES_PORT_5432_TCP_ADDR` and friends

Discovers a link to the official `postgres` Docker container and configures Django `DATABASES`.

## `POSTGRES_HOST`

## `POSTGRES_PORT`

## `POSTGRES_USER` or `POSTGRES_USERNAME`

Defaults to `postgres`.

## `POSTGRES_PASS` or `POSTGRES_PASSWORD`

## `POSTGRES_DB` or `POSTGRES_DATABASE`

## `SENTRY_DSN`

Set this to `https://xxx:yyy@sentry.company.org/123` to enable Sentry reporting.

# Custom local Django settings

Place the config file at your Docker host (e.g. at `/srv/app/config/local_settings.py`):

```
from .settings import *
from .settings_docker import *

EMAIL_HOST = 'mail.company.org'
```

Then run Docker container with `-v /srv/app/config/local_settings.py:/app/src/app/local_settings.py`
