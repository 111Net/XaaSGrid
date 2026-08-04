#!/bin/bash


if [ -z "$1" ]
then
echo "Usage:"
echo "./restore-platform.sh backup-folder"
exit 1
fi


docker exec -i xaasgrid-postgres \
psql -U eaas_user eaas_db \
< "$1/database.sql"


echo "Restore completed"
