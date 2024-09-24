ARG VARIANT=2.7
FROM docker.io/phusion/passenger-ruby27 AS ruby27
# FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT} AS ruby27
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
RUN cd /fromthepage && rm -rf test_data spec && sed -i -e 's/^ruby.*$//' Gemfile
# Remove the exact Ruby version, so that Ruby 2.7.8 is acceptable to bundler
# RUN sed -i -e 's/^ruby.*$//' Gemfile

# --------------------
FROM ruby27 AS builder
ARG BUNDLER_VERSION=2.4.22
# WORKDIR /home
WORKDIR /home/fromthepage
COPY --from=src /fromthepage /home/fromthepage
# Install required gems
#    bundle install
RUN gem install bundler -v ${BUNDLER_VERSION}
# RUN gem install nokogiri -v 1.15.5
# RUN add-apt-repository ppa:rock-core/qt4
# RUN apt update
# RUN apt-get install -y qt4-default libqtwebkit4 libqtwebkit-dev
# RUN apt-get install libqtwebkit4 -y
# RUN apt-get install libqtwebkit-dev -y
# RUN gem install capybara-webkit -v '1.15.1'
# RUN cd fromthepage; bundle install; bundle add sqlite3 -v 1.6.9

# All gems are loaded on application startup, so we need to install them all
# ENV BUNDLE_WITHOUT=development:test
RUN bundle install
# RUN bundle config set --local deployment 'true' && bundle install

# ------------------
FROM builder AS production
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV FTP_DEVISE_STRETCHES=10
COPY production.rb /home/fromthepage/config/environments/
COPY database.yml /home/fromthepage/config/database.yml
COPY 01fromthepage.rb secret_token.rb devise.rb /home/fromthepage/config/initializers/
COPY fromthepage.sh /home/fromthepage/fromthepage.sh
RUN bundle exec rails assets:precompile
# Configure MySQL

# Then update the config/database.yml file to point to the MySQL user account and database you created above.
# Run
#    rake db:migrate
# to load the schema definition into the database account.

# Finally, start the application

EXPOSE 3000
VOLUME ["/home/fromthepage/config", "/home/fromthepage/log", "/home/fromthepage/public/images/working", "/home/fromthepage/public/uploads", "/home/fromthepage/tmp", "/home/fromthepage/public/images/uploaded", "/home/fromthepage/public/text"]
CMD ["./fromthepage.sh"]
