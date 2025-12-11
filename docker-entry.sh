#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  echo "Removing stale server PID file at tmp/pids/server.pid...."
  rm tmp/pids/server.pid
fi

echo "Running migrations..."
bundle exec rails db:migrate

exec bundle exec "$@"