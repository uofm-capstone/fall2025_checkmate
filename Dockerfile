# Use the correct Ruby version
FROM ruby:3.2.1-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    nodejs \
    npm \
    postgresql-dev \
    tzdata \
    git \
    imagemagick \
    yarn

# Set working directory
WORKDIR /app

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Fix Bundler issues and install gems
RUN bundle config set --local without 'development test' && bundle install

# Copy package.json and install frontend dependencies
COPY package.json yarn.lock ./
RUN yarn install --production

# Copy the rest of the application
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose the required port
EXPOSE 8080

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]
