#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"
REPORT="$ROOT/sprint18.1-phase2-repair-report.txt"

cd "$ROOT"

echo "====================================" | tee "$REPORT"
echo "Sprint 18.1 Phase 2 Repair" | tee -a "$REPORT"
echo "$(date)" | tee -a "$REPORT"
echo "====================================" | tee -a "$REPORT"


echo ""
echo "[1] Searching dashboard configuration..."

find . \
-name "docker-compose.yml" \
-o -name "docker-compose.yaml" \
| tee -a "$REPORT"


echo ""
echo "[2] Checking dashboard directory..."

if [ -d apps/dashboard ]; then
    echo "Dashboard directory exists" | tee -a "$REPORT"
else
    echo "ERROR: apps/dashboard missing" | tee -a "$REPORT"
    exit 1
fi


echo ""
echo "[3] Checking docker compose dashboard service..."

grep -n "dashboard" docker-compose.yml \
>> "$REPORT" || true


echo ""
echo "[4] Fixing API exposed port..."

sed -i \
's/4100:4000/4000:4000/g' \
docker-compose.yml


echo ""
echo "[5] Rebuilding dashboard service..."

docker compose build dashboard || \
docker compose build xaasgrid-dashboard


echo ""
echo "[6] Restarting stack..."

docker compose down --remove-orphans

docker compose up -d


echo ""
echo "[7] Final containers..."

docker ps \
--format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
| tee -a "$REPORT"


echo ""
echo "Phase 2 repair completed"
