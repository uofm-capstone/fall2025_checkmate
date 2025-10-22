#!/bin/sh
set -e

[ -f tmp/pids/server.pid ] && rm tmp/pids/server.pid

# TEMP: skip asset precompile at boot to avoid startup timeout
# If you want a toggle, use: if [ "${PRECOMPILE_ON_BOOT}" = "1" ]; then ... fi

echo "Starting Rails on PORT=${PORT:-8080} RAILS_ENV=${RAILS_ENV:-production} ..."
exec bundle exec rails server -e "${RAILS_ENV:-production}" -b 0.0.0.0 -p "${PORT:-8080}"