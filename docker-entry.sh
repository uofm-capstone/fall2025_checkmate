#!/bin/sh
set -e

[ -f tmp/pids/server.pid ] && rm tmp/pids/server.pid

# Precompile assets at runtime if in production and not already present
if [ "${RAILS_ENV:-production}" = "production" ] && [ ! -d "public/assets" ]; then
  echo "Precompiling assets…"
  bundle exec rake assets:precompile
fi

# Start the server on Cloud Run’s port
exec bundle exec rails server -e "${RAILS_ENV:-production}" -b 0.0.0.0 -p "${PORT:-8080}"