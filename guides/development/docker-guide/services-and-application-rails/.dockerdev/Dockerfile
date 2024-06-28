FROM ruby:<ruby-version>-alpine

ARG BUNDLER_VERSION

# Install system dependencies
RUN apk --update add less bash git curl wget build-base && \
    apk add postgresql-client && \
    apk add postgresql-dev && \
    apk add tzdata && \
    apk add nodejs yarn && \
    apk add vim imagemagick && \
    rm -rf /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

ENV LANG=C.UTF-8

# Configure bundler
#   https://bundler.io/v2.1/guides/bundler_docker_guide.html
ENV GEM_HOME=/bundle
ENV PATH /app/bin:$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

# Create a directory for the app code
RUN mkdir -p /app

WORKDIR /app
