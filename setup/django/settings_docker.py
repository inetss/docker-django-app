from settings import *
import os

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
			'USER': os.getenv('POSTGRES_USER') or os.getenv('POSTGRES_USERNAME'),
			'PASSWORD': os.getenv('POSTGRES_PASSWORD') or os.getenv('POSTGRES_PASS'),
			'NAME': os.getenv('POSTGRES_DATABASE') or os.getenv('POSTGRES_DB'),
		},
	}

ALLOWED_HOSTS = list(filter(None, os.getenv('DJANGO_ALLOWED_HOSTS', '').split(',')))

DEBUG = bool(os.getenv('DJANGO_DEBUG'))

RAVEN_DSN = os.getenv('RAVEN_DSN')
if RAVEN_DSN:
	RAVEN_CONFIG = {'dsn': RAVEN_DSN}
	INSTALLED_APPS = list(INSTALLED_APPS) + ['raven.contrib.django.raven_compat']
