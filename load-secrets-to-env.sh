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
if [ -f "/run/secrets/app_secret_key_base" ]
then
  export FTP_SECRET_KEY_BASE=$(cat /run/secrets/app_secret_key_base)
fi
if [ -f "/run/secrets/devise_secret_key" ]
then
  export FTP_DEVISE_SECRET_KEY=$(cat /run/secrets/devise_secret_key)
fi
if [ -f "/run/secrets/devise_pepper" ]
then
  export FTP_DEVISE_PEPPER=$(cat /run/secrets/devise_pepper)
fi
if [ -f "/run/secrets/devise_stretches" ]
then
  export FTP_DEVISE_STRETCHES=$(cat /run/secrets/devise_stretches)
fi
