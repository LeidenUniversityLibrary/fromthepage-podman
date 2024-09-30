#!/bin/bash
if [ -f "/run/secrets/db_host" ]
then
  echo "env FTP_DATABASE_HOST=$(cat /run/secrets/db_host);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/db_name" ]
then
  echo "env FTP_DATABASE=$(cat /run/secrets/db_name);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/db_user" ]
then
  echo "env FTP_DATABASE_USERNAME=$(cat /run/secrets/db_user);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/db_password" ]
then
  echo "env FTP_DATABASE_PASSWORD=$(cat /run/secrets/db_password);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/app_secret_key_base" ]
then
  echo "env FTP_SECRET_KEY_BASE=$(cat /run/secrets/app_secret_key_base);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/devise_secret_key" ]
then
  echo "env FTP_DEVISE_SECRET_KEY=$(cat /run/secrets/devise_secret_key);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/devise_pepper" ]
then
  echo "env FTP_DEVISE_PEPPER=$(cat /run/secrets/devise_pepper);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
if [ -f "/run/secrets/devise_stretches" ]
then
  echo "env FTP_DEVISE_STRETCHES=$(cat /run/secrets/devise_stretches);" >> /etc/nginx/main.d/fromthepage-env.conf
fi
