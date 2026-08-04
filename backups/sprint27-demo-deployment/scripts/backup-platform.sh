#!/bin/bash

set -e


DATE=$(date +%F-%H%M)

mkdir -p backups/$DATE


docker exec xaasgrid-postgres \
pg_dump -U eaas_user eaas_db \
> backups/$DATE/database.sql


cp .env backups/$DATE/ 2>/dev/null || true


echo "Backup completed:"
echo backups/$DATE
