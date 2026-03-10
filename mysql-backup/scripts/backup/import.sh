#!/bin/bash

set -eu

if [ -f /.env ]; then
  set -a
  source /.env
  set +a
fi

if [ -f /scripts/.my.cnf ]; then
  MYSQL_OPTS="--defaults-extra-file=/scripts/.my.cnf"
  MYSQL_HOST="${MYSQL_HOST:-localhost}"
  MYSQL_PORT="${MYSQL_PORT:-3306}"
else
  MYSQL_OPTS="-u$MYSQL_USER -p$MYSQL_PASSWORD"
fi

COMPRESSION_LEVEL="${COMPRESSION_LEVEL:-6}"
if command -v pigz &> /dev/null; then
    DECOMPRESSOR="pigz -d -p4"
else
    DECOMPRESSOR="gunzip -c"
fi

DB_NAME="${1:-}"
SQL_FILE="${2:-}"

if [ -z "$DB_NAME" ] || [ -z "$SQL_FILE" ]; then
  echo "Usage: $0 <database> <sql_file>"
  echo "Example: $0 mydatabase backup.sql"
  echo "Example: $0 mydatabase backup.sql.gz"
  exit 1
fi

if [ ! -f "$SQL_FILE" ]; then
  echo "Error: File '$SQL_FILE' not found"
  exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting import: $SQL_FILE → $DB_NAME"

if [[ "$SQL_FILE" == *.gz ]]; then
  $DECOMPRESSOR < "$SQL_FILE" | mysql $MYSQL_OPTS -h"$MYSQL_HOST" -P"$MYSQL_PORT" "$DB_NAME" 2>/dev/null
else
  mysql $MYSQL_OPTS -h"$MYSQL_HOST" -P"$MYSQL_PORT" "$DB_NAME" < "$SQL_FILE" 2>/dev/null
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Import success: $DB_NAME"
