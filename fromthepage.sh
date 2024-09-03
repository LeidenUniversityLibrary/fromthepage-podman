#!/bin/bash
if [ -f "/run/secrets/db_host" ]
then
  export FTP_DATABASE_HOST=$(cat /run/secrets/db_host)
fi
if [ -f "/run/secrets/db_name" ]
then
  export FTP_DATABASE=$(cat /run/secrets/db_name)
fi
if [ -f "/run/secrets/db_user" ]
then
  export FTP_DATABASE_USERNAME=$(cat /run/secrets/db_user)
fi
if [ -f "/run/secrets/db_password" ]
then
  export FTP_DATABASE_PASSWORD=$(cat /run/secrets/db_password)
fi

bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0
