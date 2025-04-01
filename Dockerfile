FROM ruby:3.2.1-alpine

# Install system dependencies
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  nodejs \
  yarn \
  tzdata \
  git \
  imagemagick \
  bash \
  libffi-dev \
  curl

# Set working directory
WORKDIR /app

# Set environment
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test"

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

# Copy package.json and install JS deps
COPY package.json yarn.lock ./
RUN yarn install --production

# Copy the entire app
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose the port Cloud Run expects
EXPOSE 8080

# Start the Puma server
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:${PORT}"]
