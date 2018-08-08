#!/bin/bash


cd /opt/src

echo "Hey, we made it here!"

./build/wait-for-it.sh dj-postgres:5432

./build/run-app.sh




