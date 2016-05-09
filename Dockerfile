FROM ubuntu:16.04

ENV LANG=en_US.UTF-8

RUN locale-gen en_US.UTF-8 \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
		git \
		libjpeg-dev \
		libpq-dev \
		nginx \
		postgresql-client \
		python \
		python-dev \
		python-pip \
		python3 \
		python3-dev \
		python3-pip \
		sudo \
		supervisor \
		uwsgi \
		uwsgi-plugin-python \
		uwsgi-plugin-python3 \
	&& rm -rf /var/lib/apt/lists/*

COPY setup /setup/
RUN ln -s /setup/supervisor/app.conf /etc/supervisor/conf.d/ \
	&& ln -s /setup/uwsgi/app.ini /etc/uwsgi/apps-enabled/ \
	&& ln -sf /setup/nginx/default /etc/nginx/sites-enabled/ \
	&& ln -s /setup/entrypoint.sh /

# Default Ubuntu entrypoint is bash, keep it
CMD ["/entrypoint.sh"]

EXPOSE 80

ONBUILD ARG PYTHON_SUFFIX=3
ONBUILD ENV PYTHON_SUFFIX=$PYTHON_SUFFIX \
	python=python${PYTHON_SUFFIX}
ONBUILD RUN sed -i -e "s/plugins=.*/plugins=$python/" /etc/uwsgi/apps-enabled/app.ini
ONBUILD COPY requirements.txt /app/
ONBUILD RUN pip${PYTHON_SUFFIX} install -r /app/requirements.txt
ONBUILD COPY . /app/
ONBUILD RUN /setup/setup_app.sh
VOLUME /app/var/media
