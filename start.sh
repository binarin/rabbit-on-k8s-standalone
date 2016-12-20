#!/usr/bin/env bash
set -euo pipefail

COOKIE_FILE=/var/lib/rabbitmq/.erlang.cookie
echo -n $ERLANG_COOKIE > $COOKIE_FILE
chown rabbitmq:rabbitmq $COOKIE_FILE
chmod 0400 $COOKIE_FILE

exec gosu rabbitmq /usr/lib/rabbitmq/bin/rabbitmq-server
