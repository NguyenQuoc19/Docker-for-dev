#!/bin/bash

SERVER_IP="${1:-localhost}"
PORT="${2:-8080}"

echo "===== Backup Files List ====="
echo "Server: $SERVER_IP:$PORT"
echo ""

curl -s "http://$SERVER_IP:$PORT/" | sed 's/<a href="/\n/g' | grep '\.sql\.gz"' | sed 's/".*//g' | sed 's/^/Download: http:\/\/'$SERVER_IP':'$PORT'\//g'

echo ""
echo "===== Quick Download ====="
echo "curl -O http://$SERVER_IP:$PORT/<filename.sql.gz>"
echo ""
