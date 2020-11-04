FROM ruby:2.6.6-alpine

RUN apk update && apk add build-base git nodejs postgresql-dev postgresql-client --no-cache yarn

# Make busybox and pry work nicely for large output
ENV PAGER='more'

ENV RAILS_ROOT /var/www/tictactoe
RUN mkdir  -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ENV RAILS_ENV='production'
ENV RACK_ENV='production'

COPY Gemfile Gemfile.lock ./
RUN bundle install --full-index

COPY package.json yarn.lock ./
RUN set -ex; \
  yarn install --frozen-lockfile --production; \
  yarn cache clean;

COPY . .

# Build production assets into image
# Need keys to be set to start server but they don't need to be valid
ENV SECRET_KEY_BASE bunchofgarbage
ENV DATABASE_URL postgresql://just@start:5432/theserver
ENV REDIS_BASE_URL redis://please:6379/0
RUN bin/bundle exec rake assets:precompile

# Replace this with yourself
LABEL maintainer="Vladimir <saponko@gmail.com>"

# Set Rails to run in production
ENV RAILS_SERVE_STATIC_FILES true

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
