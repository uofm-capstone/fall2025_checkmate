# ======= STAGE 1: Build Dependencies =======
FROM ruby:3.2.1-alpine AS builder

# Install required dependencies
RUN apk add --no-cache \
    build-base \
    nodejs=16.20.0 \
    npm==8.19.4 \
    postgresql-dev \
    tzdata \
    git \
    imagemagick \
    yarn

# Set the working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && bundle install

# Copy package.json and install Node.js dependencies
COPY package.json yarn.lock ./
RUN yarn install --production

# Copy the entire application
COPY . .

# Precompile assets (for production use)
RUN bundle exec rake assets:precompile


# ======= STAGE 2: Minimal Runtime Image =======
FROM ruby:3.2.1-alpine

# Install minimal dependencies
RUN apk add --no-cache nodejs tzdata postgresql-dev

# Set the working directory
WORKDIR /app

# Copy files from the builder stage
COPY --from=builder /app /app

# Expose port 8080 for Google Cloud Run
EXPOSE 8080

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]
