# syntax=docker/dockerfile:1
FROM docker.io/phusion/passenger-ruby27 AS ruby27-base
# Update packages from base image
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade && \
    DEBIAN_FRONTEND=noninteractive apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV RAILS_ENV="production"
ENV BUNDLE_PATH=/home/app/fromthepage/vendor/bundle

# --------------------
FROM busybox AS src
ARG REPO=https://github.com/benwbrum/fromthepage.git
ARG FTP_VERSION=development

# Clone the repository
ADD ${REPO}#${FTP_VERSION} /fromthepage
WORKDIR /fromthepage
COPY production.rb /fromthepage/config/environments/
COPY database.yml /fromthepage/config/database.yml
RUN --mount=type=bind,source=fix-routes.txt,target=/tmp/fix-routes.txt \
    sed -i "" -E -f /tmp/fix-routes.txt /fromthepage/config/routes.rb
COPY 01fromthepage.rb secret_token.rb devise.rb /fromthepage/config/initializers/
COPY load-secrets-to-env.sh /fromthepage/
# Remove the exact Ruby version, so that Ruby 2.7.8 is acceptable to bundler
RUN rm -rf test_data spec .github .git .settings .autocode .devcontainer
RUN sed -i "" -e 's/^ruby.*$//' Gemfile
RUN sed -i "" -E -e '/newrelic/d' -e '/capistrano/d' -e '/puma/d' Gemfile 

# --------------------
FROM ruby27-base AS build
ARG BUNDLER_VERSION=2.4.22
ARG DEBIAN_FRONTEND=noninteractive
LABEL org.opencontainers.image.authors="Ben Companjen <ben@companjen.name>"
LABEL org.opencontainers.image.source="https://github.com/LeidenUniversityLibrary/fromthepage-podman"

# Install build deps for gems installed by bundler
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    imagemagick libmagickwand-dev \
    $(apt-get -s build-dep ruby-rmagick | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v 'ruby') \
    $(apt-get -s build-dep ruby-mysql2 | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v -e 'mysql-' -e 'ruby') && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

# Make yarn available
RUN corepack enable

USER app
WORKDIR /home/app
# RUN gem install bundler -v ${BUNDLER_VERSION}
COPY --from=src --chown=app:app /fromthepage /home/app/fromthepage
WORKDIR /home/app/fromthepage


# Install required gems
# All gems are loaded on application startup, so we need to install them all
# See https://github.com/benwbrum/fromthepage/issues/4316
# and https://github.com/benwbrum/fromthepage/issues/4291
# ENV BUNDLE_WITHOUT=development:test

RUN bundle install
RUN rm -rf ~/.bundle/ \
    "${BUNDLE_PATH}"/ruby/*/cache \
    "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git \
    "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.github
RUN ls ./vendor/bundle/ruby/2.7.0/gems && \
    du -h -d 3 .
RUN bundle exec bootsnap precompile --gemfile
# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ------------------
FROM ruby27-base AS production

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    imagemagick libmagickwand-dev \
    graphviz tzdata \
    ghostscript \
    pandoc \
    texlive-xetex \
    texlive-latex-base \
    # texlive-extra-utils \
    texlive-fonts-recommended \
    lmodern \
    pdf2svg \
    poppler-utils \
    $(apt-get -s build-dep ruby-rmagick | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v 'ruby') \
    $(apt-get -s build-dep ruby-mysql2 | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v -e 'mysql-' -e 'ruby') && \
    DEBIAN_FRONTEND=noninteractive apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

COPY --from=build --chown=app:app /home/app/fromthepage /home/app/fromthepage
# Load nginx configuration
RUN rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default
ADD fromthepage-env.conf /etc/nginx/main.d/fromthepage-env.conf
ADD nginx-fromthepage.conf /etc/nginx/sites-enabled/fromthepage.conf
ADD fromthepage-stats.sh /etc/cron.daily/fromthepage-stats
# Add init script
RUN mkdir -p /etc/my_init.d
COPY app_01-load-secrets-to-nginx-conf.sh app_10-fromthepage.sh /etc/my_init.d/

# VOLUME ["/home/fromthepage/config", "/home/fromthepage/log", "/home/fromthepage/public/images/working", "/home/fromthepage/public/uploads", "/home/fromthepage/tmp", "/home/fromthepage/public/images/uploaded", "/home/fromthepage/public/text"]
# This command starts our services.
CMD ["/sbin/my_init"]
