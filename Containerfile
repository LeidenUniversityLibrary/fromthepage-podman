ARG VARIANT=2.7
FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT} AS ruby27
MAINTAINER Ben Companjen <ben@companjen.name>

# Install the Ubuntu packages.
# Install Ruby, RubyGems, Bundler, ImageMagick, MySQL and Git
# Install qt4/qtwebkit libraries for capybara
# Install build deps for gems installed by bundler
# RUN add-apt-repository 'deb http://archive.ubuntu.com/ubuntu focal universe'
RUN apt-get update && apt-get install -y imagemagick libmagickwand-dev \
    git \
    graphviz tzdata \
    build-essential && \
    apt-get install -y \
      $(apt-get -s build-dep ruby-rmagick | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v 'ruby') && \
    apt-get install -y \
      $(apt-get -s build-dep ruby-mysql2 | grep '^(Inst|Conf) ' | cut -d' ' -f2 | fgrep -v -e 'mysql-' -e 'ruby') && \
    apt-get install -y nodejs

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

FROM ruby27
ARG REPO=https://github.com/benwbrum/fromthepage.git
ARG FTP_VERSION=development
WORKDIR /home

# Clone the repository
RUN git clone -b ${FTP_VERSION} --depth 1 $REPO fromthepage
COPY database.yml /home/fromthepage/config/database.yml

# Install required gems
#    bundle install
RUN gem install bundler -v 2.4.22
# RUN gem install nokogiri -v 1.15.5
# RUN add-apt-repository ppa:rock-core/qt4
# RUN apt update
# RUN apt-get install -y qt4-default libqtwebkit4 libqtwebkit-dev
# RUN apt-get install libqtwebkit4 -y
# RUN apt-get install libqtwebkit-dev -y
# RUN gem install capybara-webkit -v '1.15.1'
# RUN cd fromthepage; bundle install; bundle add sqlite3 -v 1.6.9
WORKDIR /home/fromthepage

# Remove the exact Ruby version, so that Ruby 2.7.8 is acceptable to bundler
RUN sed -i -e 's/^ruby.*$//' Gemfile
RUN bundle install
# RUN service mysql restart; ruby --version && mysql -V && false

# Configure MySQL

# Then update the config/database.yml file to point to the MySQL user account and database you created above.
# Run
#    rake db:migrate
# to load the schema definition into the database account.
# RUN find /var/lib/mysql -type f -exec touch {} \; && service mysql restart; cd fromthepage; bundle exec rake db:create; bundle exec rake db:migrate

# Finally, start the application

EXPOSE 3000
# ENV DATABASE_ADAPTER sqlite
VOLUME /data
# CMD find /var/lib/mysql -type f -exec touch {} \; && service mysql restart; cd fromthepage; bundle exec rails server
COPY fromthepage.sh /home/fromthepage/fromthepage.sh
CMD ./fromthepage.sh
