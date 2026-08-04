#!/bin/bash

set -e


echo "Deploying XaaSGrid"


./scripts/bootstrap-environment.sh


docker compose pull || true

docker compose up -d


sleep 10


curl -sf http://localhost:4000/api/health


echo

echo "Deployment successful"
