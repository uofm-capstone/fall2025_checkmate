#!/bin/sh
set -e

# Clean stale pid (Rails)
[ -f tmp/pids/server.pid ] && rm tmp/pids/server.pid

# Default: run Rails server with proper bind/port
if [ $# -eq 0 ]; then
  exec bundle exec rails server -e "${RAILS_ENV:-production}" -b 0.0.0.0 -p "${PORT:-8080}"
else
  exec bundle exec "$@"
fi
