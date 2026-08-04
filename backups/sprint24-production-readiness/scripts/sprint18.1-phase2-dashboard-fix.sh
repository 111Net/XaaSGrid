#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"

cd "$ROOT"

echo "===================================="
echo "Sprint 18.1 Phase 2.2 Dashboard Fix"
echo "$(date)"
echo "===================================="


echo "[1] Backup dashboard"

cp apps/dashboard/package.json \
apps/dashboard/package.json.phase2-backup


echo "[2] Creating Next.js Dockerfile"


cat > apps/dashboard/Dockerfile <<'EOF'
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm","start"]
EOF


echo "[3] Checking dashboard package"

cat apps/dashboard/package.json


echo "[4] Rebuilding platform"

docker compose down --remove-orphans

docker compose build xaasgrid-dashboard

docker compose up -d


echo "[5] Container validation"

docker ps \
--format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"


echo ""
echo "Checking required services"


for SERVICE in \
xaasgrid-api \
xaasgrid-dashboard \
xaasgrid-postgres \
xaasgrid-redis

do

if docker ps --format '{{.Names}}' | grep -q "$SERVICE"
then
 echo "OK: $SERVICE"
else
 echo "FAILED: $SERVICE"
 exit 1
fi

done


echo "===================================="
echo "Dashboard repair completed"
echo "===================================="
