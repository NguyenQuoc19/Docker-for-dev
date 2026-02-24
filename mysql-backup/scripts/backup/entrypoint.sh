#!/bin/bash
set -e

mkdir -p /var/log/nginx
touch /var/log/nginx/error.log
touch /var/log/nginx/access.log

CRON_SCHEDULE=${CRON_SCHEDULE:-"*/5 * * * *"}
sed -i "s|\\\${CRON_SCHEDULE}|${CRON_SCHEDULE}|g" /etc/cron.d/backup

echo "Crontab content:"
cat /etc/cron.d/backup

echo ""
echo "Starting nginx for backup downloads..."

ALLOWED_IP=${ALLOWED_IP:-all}
if [ "$ALLOWED_IP" = "all" ]; then
  ALLOWED_IP="all;"
else
  ALLOWED_IP="${ALLOWED_IP};"
fi
sed -i "s|\\\${ALLOWED_IP}|${ALLOWED_IP}|g" /etc/nginx/nginx.conf
nginx &
sleep 2

echo "Starting crond..."
/usr/sbin/cron -n

tail -f /dev/null
