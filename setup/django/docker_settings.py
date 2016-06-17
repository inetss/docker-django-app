import os
if '.' in __name__:
	from .settings import *
else:
	from settings import *

if os.getenv('MYSQL_PORT_3306_TCP_ADDR') or os.getenv('MYSQL_HOST'):
	DATABASES = {
		'default': {
			'ENGINE': 'django.db.backends.mysql',
			'HOST': os.getenv('MYSQL_PORT_3306_TCP_ADDR') or os.getenv('MYSQL_HOST'),
			'PORT': os.getenv('MYSQL_PORT_3306_TCP_PORT') or os.getenv('MYSQL_PORT'),
			'USER': os.getenv('MYSQL_USER') or os.getenv('MYSQL_USERNAME') or 'root',
			'PASSWORD': os.getenv('MYSQL_PASSWORD') or os.getenv('MYSQL_PASS') or os.getenv('MYSQL_ENV_MYSQL_ROOT_PASSWORD'),
			'NAME': os.getenv('MYSQL_DATABASE') or os.getenv('MYSQL_DB'),
		},
	}
elif os.getenv('POSTGRES_PORT_5432_TCP_ADDR') or os.getenv('POSTGRES_HOST'):
	DATABASES = {
		'default': {
			'ENGINE': 'django.db.backends.postgresql_psycopg2',
			'HOST': os.getenv('POSTGRES_PORT_5432_TCP_ADDR') or os.getenv('POSTGRES_HOST'),
			'PORT': os.getenv('POSTGRES_PORT_5432_TCP_PORT') or os.getenv('POSTGRES_PORT'),
			'USER': os.getenv('POSTGRES_USER') or os.getenv('POSTGRES_USERNAME') or 'postgres',
			'PASSWORD': os.getenv('POSTGRES_PASSWORD') or os.getenv('POSTGRES_PASS') or os.getenv('POSTGRES_ENV_POSTGRES_PASSWORD'),
			'NAME': os.getenv('POSTGRES_DATABASE') or os.getenv('POSTGRES_DB'),
		},
	}

if os.getenv('MEMCACHED_PORT_11211_TCP_ADDR') or os.getenv('MEMCACHED_LOCATION'):
	CACHES = {
		'default': {
			'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
			'LOCATION': os.getenv('MEMCACHED_LOCATION') or ':'.join([os.getenv('MEMCACHED_PORT_11211_TCP_ADDR'), os.getenv('MEMCACHED_PORT_11211_TCP_PORT')]),
			'KEY_PREFIX': os.getenv('MEMCACHED_PREFIX'),
		}
	}

ALLOWED_HOSTS = list(filter(None, os.getenv('DJANGO_ALLOWED_HOSTS', '').split(',')))

DEBUG = bool(os.getenv('DJANGO_DEBUG'))

SENTRY_DSN = os.getenv('SENTRY_DSN')
if SENTRY_DSN:
	RAVEN_CONFIG = {'dsn': SENTRY_DSN}
	INSTALLED_APPS = list(INSTALLED_APPS) + ['raven.contrib.django.raven_compat']
