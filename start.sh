#!/usr/bin/env bash
set -euo pipefail

# Store cookie provided to us in env variable by k8s secrets mechanism
COOKIE_FILE=/var/lib/rabbitmq/.erlang.cookie
echo -n $ERLANG_COOKIE > $COOKIE_FILE
chown rabbitmq:rabbitmq $COOKIE_FILE
chmod 0400 $COOKIE_FILE

# Runs rabbitmq-server in foreground. Stdout logging is very limited,
# only startup success/failure is displayed there. To see the detailed
# logs you should look into `/var/log/rabbitmq`.
exec gosu rabbitmq /usr/lib/rabbitmq/bin/rabbitmq-server
