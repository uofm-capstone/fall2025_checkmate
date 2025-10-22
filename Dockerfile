# Use the correct Ruby version
FROM ruby:3.2.1-alpine

# System deps
RUN apk add --no-cache \
  build-base nodejs npm yarn postgresql-dev tzdata git imagemagick \
  libxml2-dev libxslt-dev zlib-dev

WORKDIR /app

# ===== Build-time env (overridable) =====
ARG RAILS_ENV=production
ARG NODE_ENV=production
ENV RAILS_ENV=$RAILS_ENV NODE_ENV=$NODE_ENV

# Gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# JS deps (if you use yarn)
COPY package.json yarn.lock ./
RUN yarn install --production || true

# App code
COPY . .

# Precompile ONLY for production builds (will need secrets at build time)
# (No-op in development builds)
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY SECRET_KEY_BASE=$SECRET_KEY_BASE
RUN echo "Docker build RAILS_ENV=$RAILS_ENV NODE_ENV=$NODE_ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY SECRET_KEY_BASE=$SECRET_KEY_BASE"
#RUN if [ "$RAILS_ENV" = "production" ]; then bundle exec rake assets:precompile; fi

# Entrypoint
COPY docker-entry.sh /usr/bin/docker-entry.sh
RUN chmod +x /usr/bin/docker-entry.sh

EXPOSE 8080
ENTRYPOINT ["/usr/bin/docker-entry.sh"]
# no CMD — entrypoint provides defaults
