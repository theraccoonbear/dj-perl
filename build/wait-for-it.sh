#!/bin/bash

set -e

shift
cmd="$@"

until nc -z postgres 5432; do
    echo "$(date) - waiting for postgres..."
    sleep 1
done

cd /opt/src && npm install;

cd /opt/src

echo 'Zzzz...';
while sleep 3600; do
  echo 'Zzzz...';
done

# node --harmony ./scripts/createdb.js

# ./scripts/run-sequelize-from-inside-container.sh db:migrate

# >&2 echo "Postgres is ready - executing command"

# nodemon --ignore "public/*"
