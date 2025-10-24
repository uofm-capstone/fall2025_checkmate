#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  echo "Removing stale server PID file at tmp/pids/server.pid...."
  rm tmp/pids/server.pid
fi

if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
  echo "Running migrations..."
  bundle exec rails db:migrate
fi

exec bundle exec "$@"