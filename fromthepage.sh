#!/bin/bash
if [ -f "/run/secrets/db_host" ]
then
  export FTP_DATABASE_HOST=$(cat /run/secrets/db_host)
  echo "env FTP_DATABASE_HOST=$(cat /run/secrets/db_host);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/db_name" ]
then
  export FTP_DATABASE=$(cat /run/secrets/db_name)
  echo "env FTP_DATABASE=$(cat /run/secrets/db_name);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/db_user" ]
then
  export FTP_DATABASE_USERNAME=$(cat /run/secrets/db_user)
  echo "env FTP_DATABASE_USERNAME=$(cat /run/secrets/db_user);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/db_password" ]
then
  export FTP_DATABASE_PASSWORD=$(cat /run/secrets/db_password)
  echo "env FTP_DATABASE_PASSWORD=$(cat /run/secrets/db_password);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/app_secret_key_base" ]
then
  export FTP_SECRET_KEY_BASE=$(cat /run/secrets/app_secret_key_base)
  echo "env FTP_SECRET_KEY_BASE=$(cat /run/secrets/app_secret_key_base);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/devise_secret_key" ]
then
  export FTP_DEVISE_SECRET_KEY=$(cat /run/secrets/devise_secret_key)
  echo "env FTP_DEVISE_SECRET_KEY=$(cat /run/secrets/devise_secret_key);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/devise_pepper" ]
then
  export FTP_DEVISE_PEPPER=$(cat /run/secrets/devise_pepper)
  echo "env FTP_DEVISE_PEPPER=$(cat /run/secrets/devise_pepper);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/devise_stretches" ]
then
  export FTP_DEVISE_STRETCHES=$(cat /run/secrets/devise_stretches)
  echo "env FTP_DEVISE_STRETCHES=$(cat /run/secrets/devise_stretches);" >> /etc/nginx/main.d/fromthepage-env.conf
fi

cd /home/app/fromthepage && /sbin/setuser app bundle exec rails db:prepare
