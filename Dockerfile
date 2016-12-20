FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
 && echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends socat logrotate \
 && apt-get install -t jessie-backports -y --no-install-recommends erlang-nox wget ca-certificates \
 && apt-get clean \
 && rm -f /etc/apt/sources.list.d/backports.list

# We need at least 3.6.6, as it'll contain https://github.com/rabbitmq/rabbitmq-server/pull/892
RUN set -x \
 && wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.6/rabbitmq-server_3.6.6-1_all.deb -O /tmp/rabbit.deb \
 && dpkg -i /tmp/rabbit.deb \
 && rm -f /tmp/rabbit.deb

# `cp` is needed until https://github.com/rabbitmq/rabbitmq-server/pull/1016 is merged
RUN set -x \
 && wget https://github.com/Mirantis/rabbitmq-autocluster/releases/download/0.6.1.950/rabbitmq-autocluster_0.6.1.950-1_all.deb -O /tmp/ac.deb \
 && dpkg -i /tmp/ac.deb \
 && cp -v /usr/lib/rabbitmq/plugins/*.ez /usr/lib/rabbitmq/lib/rabbitmq_server-*/plugins/ \
 && rm -f /tmp/ac.deb

ENV GOSU_VERSION 1.9
RUN set -x \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true

COPY enabled_plugins /etc/rabbitmq/enabled_plugins
COPY rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf
COPY start.sh /start.sh
