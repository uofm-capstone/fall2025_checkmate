# ======= STAGE 1: Build Node.js Dependencies =======
FROM node:19.8.1-alpine AS node_build

# Set the working directory
WORKDIR /app

# Copy package.json and install Node.js dependencies
COPY package.json yarn.lock ./
RUN yarn install --production

# ======= STAGE 2: Build Ruby & Rails Dependencies =======
FROM ruby:3.2.1-alpine AS builder

# Install required dependencies (Node.js is handled separately)
RUN apk add --no-cache \
    build-base \
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

# Copy Node.js dependencies from the node_build stage
COPY --from=node_build /app/node_modules /app/node_modules
COPY . .

# Precompile assets (for production use)
RUN bundle exec rake assets:precompile

# ======= STAGE 3: Minimal Runtime Image =======
FROM ruby:3.2.1-alpine

# Install minimal dependencies
RUN apk add --no-cache tzdata postgresql-dev

# Set the working directory
WORKDIR /app

# Copy everything from the builder stage (Rails app)
COPY --from=builder /app /app

# Expose port 8080 for Google Cloud Run
EXPOSE 8080

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]
