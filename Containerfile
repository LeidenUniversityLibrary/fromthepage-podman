FROM docker.io/phusion/passenger-ruby27 AS ruby27-base
# Update packages from base image
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade && \
    DEBIAN_FRONTEND=noninteractive apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

FROM ruby27-base AS ruby27
LABEL org.opencontainers.image.authors="Ben Companjen <ben@companjen.name>"

# Install the Ubuntu packages.
# Install Ruby, RubyGems, Bundler, ImageMagick, MySQL and Git
# Install qt4/qtwebkit libraries for capybara
# Install build deps for gems installed by bundler
# RUN add-apt-repository 'deb http://archive.ubuntu.com/ubuntu focal universe'
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    imagemagick libmagickwand-dev \
    graphviz tzdata \
    ghostscript \
    pandoc \
    texlive-xetex \
    texlive-latex-base \
    pdf2svg \
    poppler-utils \
    build-essential && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      $(apt-get -s build-dep ruby-rmagick | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v 'ruby') && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      $(apt-get -s build-dep ruby-mysql2 | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v -e 'mysql-' -e 'ruby') && \
    DEBIAN_FRONTEND=noninteractive apt clean

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# --------------------
FROM busybox AS src
ARG REPO=https://github.com/benwbrum/fromthepage.git
ARG FTP_VERSION=development

# Clone the repository
ADD ${REPO}#${FTP_VERSION} /fromthepage
WORKDIR /fromthepage
COPY production.rb /fromthepage/config/environments/
COPY database.yml /fromthepage/config/database.yml
COPY 01fromthepage.rb secret_token.rb devise.rb /fromthepage/config/initializers/
COPY load-secrets-to-env.sh /fromthepage/
# Remove the exact Ruby version, so that Ruby 2.7.8 is acceptable to bundler
RUN rm -rf test_data spec && sed -i -e 's/^ruby.*$//' Gemfile

# --------------------
FROM ruby27 AS builder
ARG BUNDLER_VERSION=2.4.22

USER app
WORKDIR /home/app
COPY --from=src --chown=app:app /fromthepage /home/app/fromthepage
WORKDIR /home/app/fromthepage

RUN gem install bundler -v ${BUNDLER_VERSION}

# Install required gems
# All gems are loaded on application startup, so we need to install them all
# See https://github.com/benwbrum/fromthepage/issues/4316
# and https://github.com/benwbrum/fromthepage/issues/4291
# ENV BUNDLE_WITHOUT=development:test

# At some point we may want to use a separate build stage to install the gems,
# precompile the assets and then copy them to a leaner image to run.
# By setting the `deployment` flag, bundler install the gems within the app directory.
# RUN bundle config set --local deployment 'true' && bundle install
RUN bundle install --jobs 3
RUN bundle exec rails assets:precompile

# ------------------
FROM builder AS production
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}

USER root
# Load nginx configuration
RUN rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default
ADD fromthepage-env.conf /etc/nginx/main.d/fromthepage-env.conf
ADD nginx-fromthepage.conf /etc/nginx/sites-enabled/fromthepage.conf
# Add init script
RUN mkdir -p /etc/my_init.d
COPY app_01-load-secrets-to-nginx-conf.sh app_10-fromthepage.sh /etc/my_init.d/

# VOLUME ["/home/fromthepage/config", "/home/fromthepage/log", "/home/fromthepage/public/images/working", "/home/fromthepage/public/uploads", "/home/fromthepage/tmp", "/home/fromthepage/public/images/uploaded", "/home/fromthepage/public/text"]
# This command starts our services.
CMD ["/sbin/my_init"]
