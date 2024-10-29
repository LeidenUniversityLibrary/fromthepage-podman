#!/bin/bash

setuser app echo "Starting email stats at $(date)" >> /home/app/fromthepage/log/cron.log
. /home/app/fromthepage/load-secrets-to-env.sh
. /etc/cron.env
cd /home/app/fromthepage
/sbin/setuser app bundle exec rake fromthepage:email_stats[24] >> /home/app/fromthepage/log/cron.log 2>&1
