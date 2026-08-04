#!/bin/bash

set -e

echo "=========================================="
echo "Sprint 21 Dashboard Runtime Fix"
echo "=========================================="


cd /data/eaasgrid-platform


echo "[1] Backup environment"

mkdir -p backups/sprint21-runtime-fix

cp apps/dashboard/.env \
backups/sprint21-runtime-fix/dashboard.env.backup 2>/dev/null || true


echo "[2] Fixing Docker API endpoint"


cat > apps/dashboard/.env <<EOF

NEXT_PUBLIC_API_URL=http://xaasgrid-api:4000/api

EOF


echo "[3] Rebuilding dashboard"

docker compose build xaasgrid-dashboard


echo "[4] Restarting dashboard"

docker compose up -d xaasgrid-dashboard


echo "[5] Waiting"

sleep 15


echo "[6] Dashboard test"

curl -I http://localhost:3000


echo


echo "[7] API test"

curl http://localhost:4000/api/platform/metrics


echo


echo "=========================================="
echo "Sprint 21 Dashboard Runtime Fix Complete"
echo "=========================================="
