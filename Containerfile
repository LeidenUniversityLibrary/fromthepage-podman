ARG VARIANT=2.7
FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT} AS ruby27
LABEL org.opencontainers.image.authors="Ben Companjen <ben@companjen.name>"

# Install the Ubuntu packages.
# Install Ruby, RubyGems, Bundler, ImageMagick, MySQL and Git
# Install qt4/qtwebkit libraries for capybara
# Install build deps for gems installed by bundler
# RUN add-apt-repository 'deb http://archive.ubuntu.com/ubuntu focal universe'
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    imagemagick libmagickwand-dev \
    git \
    graphviz tzdata \
    build-essential \
    nodejs && \
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

FROM busybox AS src
ARG REPO=https://github.com/benwbrum/fromthepage.git
ARG FTP_VERSION=development

# Clone the repository
ADD ${REPO}#${FTP_VERSION} /fromthepage
RUN cd /fromthepage && rm -rf travis test_data spec

FROM ruby27
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

# Remove the exact Ruby version, so that Ruby 2.7.8 is acceptable to bundler
RUN sed -i -e 's/^ruby.*$//' Gemfile
ENV RAILS_ENV=production
# All gems are loaded on application startup, so we need to install them all
# ENV BUNDLE_WITHOUT=development:test
RUN bundle install
# RUN bundle config set --local deployment 'true' && bundle install
RUN bundle exec rake assets:precompile
# Configure MySQL

# Then update the config/database.yml file to point to the MySQL user account and database you created above.
# Run
#    rake db:migrate
# to load the schema definition into the database account.

# Finally, start the application

EXPOSE 3000
# VOLUME /data
COPY database.yml /home/fromthepage/config/database.yml
COPY 01fromthepage.rb secret_token.rb devise.rb /home/fromthepage/config/initializers/
COPY fromthepage.sh /home/fromthepage/fromthepage.sh
CMD ["./fromthepage.sh"]
