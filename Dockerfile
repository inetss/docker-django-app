FROM ubuntu:16.04

ENV LANG=en_US.UTF-8

RUN \
	locale-gen en_US.UTF-8 && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		nginx \
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
		uwsgi-plugin-python3 && \
	rm -rf /var/lib/apt/lists/*

COPY setup /setup/
RUN /setup/setup_server.sh

# Default Ubuntu entrypoint is bash, keep it
CMD ["/entrypoint.sh"]

EXPOSE 80

RUN mkdir -p /app/var/media && chown www-data /app/var/media
VOLUME /app/var/media

# Rare changes
ONBUILD COPY requirements.txt /app/
ONBUILD COPY src/manage.py /app/src/
ONBUILD RUN /setup/setup_requirements.sh

# Frequent changes
ONBUILD COPY . /app/
ONBUILD RUN /setup/setup_app.sh
