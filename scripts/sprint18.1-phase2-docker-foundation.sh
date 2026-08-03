#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"
REPORT="$ROOT/sprint18.1-phase2-docker-report.txt"

cd "$ROOT"

echo "====================================" | tee "$REPORT"
echo "Sprint 18.1 Phase 2 Docker Foundation" | tee -a "$REPORT"
echo "$(date)" | tee -a "$REPORT"
echo "====================================" | tee -a "$REPORT"


echo ""
echo "[1] Stopping old containers..."

docker compose down --remove-orphans || true


echo ""
echo "[2] Removing legacy containers..."

LEGACY=$(docker ps -aq \
 --filter name=eaas \
 --filter name=supabase)

if [ -n "$LEGACY" ]; then
 docker rm -f $LEGACY
fi


echo ""
echo "[3] Creating docker compose backup..."

cp docker-compose.yml \
 docker-compose.yml.phase2.backup 2>/dev/null || true


echo ""
echo "[4] Validating docker-compose.yml..."

docker compose config >> "$REPORT"


echo ""
echo "[5] Starting production stack..."

docker compose up -d --remove-orphans


echo ""
echo "[6] Container validation..."

docker ps \
 --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
 | tee -a "$REPORT"


echo ""
echo "[7] Checking required containers..."

REQUIRED="
xaasgrid-api
xaasgrid-dashboard
xaasgrid-postgres
xaasgrid-redis
"


for SERVICE in $REQUIRED
do

 if docker ps --format '{{.Names}}' | grep -q "$SERVICE"
 then
    echo "OK: $SERVICE"
 else
    echo "FAILED: $SERVICE missing"
    exit 1
 fi

done


echo ""
echo "[8] Docker foundation completed"

echo "====================================" | tee -a "$REPORT"
echo "SUCCESS" | tee -a "$REPORT"
echo "====================================" | tee -a "$REPORT"
