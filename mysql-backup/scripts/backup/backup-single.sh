#!/bin/bash

set -eu

if [ -f /.env ]; then
  set -a
  source /.env
  set +a
fi

if [ -f /scripts/.my.cnf ]; then
  MYSQL_OPTS="--defaults-extra-file=/scripts/.my.cnf"
else
  MYSQL_OPTS="-u$MYSQL_USER -p$MYSQL_PASSWORD"
fi

DB_NAME="${1:-}"

if [ -z "$DB_NAME" ]; then
  echo "Usage: $0 <database_name>"
  echo "Example: $0 test"
  exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup: $DB_NAME"

if mysqldump $MYSQL_OPTS \
    -h"$MYSQL_HOST" \
    -P"$MYSQL_PORT" \
    --single-transaction \
    --quick \
    --lock-tables=false \
    "$DB_NAME" 2>/dev/null | gzip > "$BACKUP_FILE"; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup success: $BACKUP_FILE"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup failed: $DB_NAME"
  exit 1
fi
