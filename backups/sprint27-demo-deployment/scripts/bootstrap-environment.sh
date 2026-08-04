#!/bin/bash

set -e

echo "XaaSGrid Environment Bootstrap"


mkdir -p data
mkdir -p backups
mkdir -p logs
mkdir -p certificates


if [ ! -f .env ]
then

cat > .env <<ENV

NODE_ENV=production

POSTGRES_DB=eaas_db
POSTGRES_USER=eaas_user

API_PORT=4000
DASHBOARD_PORT=3000

REDIS_PORT=6379

ENV

fi


echo "Environment ready"
