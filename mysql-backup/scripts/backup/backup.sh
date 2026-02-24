#!/bin/bash

set -eu

if [ -f /.env ]; then
  set -a
  source /.env
  set +a
fi

COMPRESSION_LEVEL="${COMPRESSION_LEVEL:-6}"
COMPRESSOR="${COMPRESSION_LEVEL}"
if command -v pigz &> /dev/null; then
    COMPRESSOR="pigz -p4 -${COMPRESSION_LEVEL}"
fi

if [ -f /scripts/.my.cnf ]; then
  MYSQL_OPTS="--defaults-extra-file=/scripts/.my.cnf"
  MYSQLADMIN_OPTS="--defaults-extra-file=/scripts/.my.cnf"
else
  MYSQL_OPTS="-u$MYSQL_USER -p$MYSQL_PASSWORD"
  MYSQLADMIN_OPTS="-u$MYSQL_USER -p$MYSQL_PASSWORD"
fi

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"
}

log "====== BACKUP START ======"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

if ! mysqladmin --defaults-extra-file=/scripts/.my.cnf ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" --silent 2>/dev/null; then
  log "[ERROR] Cannot connect to MySQL"
  exit 1
fi

log "[INFO] MySQL connection OK"

for DB in $BACKUP_DATABASES; do
  log "[INFO] Checking database: $DB"

  EXISTS=$(mysql $MYSQL_OPTS -h"$MYSQL_HOST" -P"$MYSQL_PORT" -e "SHOW DATABASES LIKE '$DB';" 2>/dev/null | grep "$DB" || true)

  if [ -z "$EXISTS" ]; then
    log "[WARN] Database '$DB' not found → skip"
    continue
  fi

  BACKUP_FILE="$BACKUP_DIR/${DB}_${TIMESTAMP}.sql.gz"
  log "[INFO] Start backup: $DB → $BACKUP_FILE"

  if mysqldump $MYSQL_OPTS -h"$MYSQL_HOST" -P"$MYSQL_PORT" \
      --single-transaction \
      --quick \
      --lock-tables=false \
      "$DB" 2>/dev/null | $COMPRESSOR > "$BACKUP_FILE"; then
    log "[SUCCESS] Backup success: $DB"
  else
    log "[ERROR] Backup failed: $DB"
  fi
done

log "[INFO] Cleanup backups older than $RETENTION_DAYS days"

DELETED=$(find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -print -delete | wc -l)

log "[INFO] Deleted $DELETED old backup file(s)"

log "====== BACKUP END ======"
echo "" >> "$LOG_FILE"
