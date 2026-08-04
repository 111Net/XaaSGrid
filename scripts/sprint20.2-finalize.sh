#!/bin/bash

set -e

echo "======================================"
echo "XaaSGrid Sprint 20.2 Finalization"
echo "======================================"

cd /data/eaasgrid-platform


echo "[1] Fixing API identity"

sed -i 's/EAASGrid API/XaaSGrid API/g' apps/api/src/server.js 2>/dev/null || true


echo "[2] Fixing environment naming"

grep -rl "EAASGrid API" apps/api/src 2>/dev/null | xargs -r sed -i 's/EAASGrid API/XaaSGrid API/g'


echo "[3] Ensuring Prisma generation in Docker"

grep -q "prisma generate" apps/api/Dockerfile || \
sed -i '/COPY . \./a RUN npx prisma generate' apps/api/Dockerfile


echo "[4] Fixing host Prisma connection"

cp .env .env.backup.$(date +%s)

sed -i 's/@xaasgrid-postgres:5432/@localhost:5432/g' .env


echo "[5] Fixing Docker runtime DATABASE_URL"

grep -q "xaasgrid-postgres" docker-compose.yml || true


echo "[6] Rebuilding API"

docker compose build --no-cache xaasgrid-api


echo "[7] Restarting platform"

docker compose up -d


echo "[8] Waiting for PostgreSQL"

sleep 10


echo "[9] Applying Prisma schema"

cd apps/api

set -a
source ../../.env
set +a

npx prisma generate
npx prisma db push


echo "[10] Restoring Docker DATABASE_URL"

cd ../..

cp .env.backup.* .env 2>/dev/null || true


echo "[11] Database verification"

docker exec xaasgrid-postgres \
psql -U eaas_user -d eaas_db \
-c "\dt"


echo "[12] API health"

curl http://localhost:4000/api/health


echo ""
echo "======================================"
echo "Sprint 20.2 Finalization Complete"
echo "======================================"
