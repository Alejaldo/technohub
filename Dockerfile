# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.3
FROM ruby:$RUBY_VERSION-slim

# Set environment variables
ENV RAILS_ENV production
ENV BUNDLER_VERSION 2.5.11

WORKDIR /app

# Install dependencies
RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev nodejs

# Install bundler
RUN gem install bundler -v "$BUNDLER_VERSION"

# Set up gems
COPY Gemfile* ./
RUN bundle install

# Copy the rest of the application code
COPY . .

# Set environment variables for precompiling assets
ARG POSTGRES_DB
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG SECRET_KEY_BASE

# Precompile assets
RUN POSTGRES_DB=$POSTGRES_DB \
    POSTGRES_USER=$POSTGRES_USER \
    POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    SECRET_KEY_BASE=$SECRET_KEY_BASE \
    bundle exec rails assets:precompile

# Expose port 3000
EXPOSE 3000

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
