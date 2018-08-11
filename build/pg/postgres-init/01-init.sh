#!/bin/bash
set -e
BASE_PSQL="psql -v ON_ERROR_STOP=1 --username=$POSTGRES_USER"

if $BASE_PSQL --file=/sql-scripts/list-databases.sql | grep $APP_DB_NAME > /dev/null 2>&1; then
  echo "$(date) - Found $APP_DB_NAME"
else
  echo "$(date) - Didn't find $APP_DB_NAME, creating..."
  $BASE_PSQL <<-EOSQL > /dev/null 2>&1
	CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASSWORD';
	CREATE DATABASE $APP_DB_NAME;
	GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME TO $APP_DB_USER;
EOSQL
fi


