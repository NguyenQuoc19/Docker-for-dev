#!/bin/bash
SQL_FILE=$1
DB_NAME=$2

docker cp bin/.my.cnf mysql_db:/root/.my.cnf
docker exec -i mysql_db mysql $DB_NAME < $SQL_FILE