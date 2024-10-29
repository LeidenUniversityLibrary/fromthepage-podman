#!/bin/bash

. /home/app/fromthepage/load-secrets-to-env.sh
declare -p | grep -E '^declare -x' > /etc/cron.env
cd /home/app/fromthepage
/sbin/setuser app bundle exec rails db:prepare
