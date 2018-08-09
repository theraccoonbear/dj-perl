#!/bin/bash
set -e
BASE_PSQL="psql -v ON_ERROR_STOP=1 --username=$POSTGRES_USER"

if $BASE_PSQL --file=/sql-scripts/list-databases.sql | grep $POSTGRES_DB > /dev/null 2>&1; then
  echo "$(date) - Found $POSTGRES_DB"
else
  echo "$(date) - Didn't find $POSTGRES_DB, creating..."
  $BASE_PSQL <<-EOSQL > /dev/null 2>&1
	CREATE DATABASE $POSTGRES_DB;
	GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
EOSQL
fi


