# ======= STAGE 1: Build Node.js Dependencies =======
FROM node:16-alpine AS node_build

WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --production

# ======= STAGE 2: Build Ruby & Rails Dependencies =======
FROM ruby:3.2.1-alpine AS builder

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    git \
    imagemagick \
    yarn \
    nodejs 

WORKDIR /app

# Install Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && bundle install

# Copy Node.js dependencies from node_build
COPY --from=node_build /app/node_modules /app/node_modules
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# ======= STAGE 3: Minimal Runtime Image =======
FROM ruby:3.2.1-alpine

RUN apk add --no-cache tzdata postgresql-dev nodejs yarn

WORKDIR /app
COPY --from=builder /app /app

# Expose port 8080 for Google Cloud Run
EXPOSE 8080

# Run the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]
