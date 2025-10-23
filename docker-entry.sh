#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  echo "Removing stale server PID file at tmp/pids/server.pid...."
  rm tmp/pids/server.pid
fi

exec bundle exec "$@"