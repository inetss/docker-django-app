FROM ubuntu:16.04

ARG PYTHON_SUFFIX=3

ENV LANG=en_US.UTF-8 \
	PYTHON_SUFFIX=$PYTHON_SUFFIX \
	python=python${PYTHON_SUFFIX}

RUN locale-gen en_US.UTF-8 \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	git \
	libjpeg-dev \
	libpq-dev \
	nginx \
	postgresql-client \
	$python \
	$python-dev \
	$python-pip \
	sudo \
	supervisor \
	uwsgi \
	uwsgi-plugin-$python

COPY setup /setup/
RUN ln -s /setup/supervisor/app.conf /etc/supervisor/conf.d/ \
	&& ln -s /setup/uwsgi/app.ini /etc/uwsgi/apps-enabled/ \
	&& ln -sf /setup/nginx/default /etc/nginx/sites-enabled/ \
	&& ln -s /setup/entrypoint.sh / \
	&& sed -i -e "s/plugins=.*/plugins=$python/" /etc/uwsgi/apps-enabled/app.ini

# Default Ubuntu entrypoint is bash, keep it
CMD ["/entrypoint.sh"]

EXPOSE 80

ONBUILD COPY requirements.txt /app/
ONBUILD RUN pip${PYTHON_SUFFIX} install -r /app/requirements.txt
ONBUILD COPY . /app/
ONBUILD RUN /setup/setup_app.sh
VOLUME /app/var/media
