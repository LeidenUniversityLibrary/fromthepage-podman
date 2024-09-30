#!/bin/bash

. /home/app/fromthepage/load-secrets-to-env.sh
cd /home/app/fromthepage && /sbin/setuser app bundle exec rails db:prepare
