#!/bin/bash

set -e

ROOT="/data/xaasgrid-platform"
REPORT="$ROOT/sprint18.1-phase1-cleanup-report.txt"
BACKUP="$ROOT/sprint18.1-backup-$(date +%Y%m%d-%H%M%S)"

cd "$ROOT"

echo "====================================" | tee "$REPORT"
echo "XaaSGrid Sprint 18.1 Phase 1 Cleanup" | tee -a "$REPORT"
echo "Started: $(date)" | tee -a "$REPORT"
echo "====================================" | tee -a "$REPORT"


echo ""
echo "[1] Creating backup..."
mkdir -p "$BACKUP"

cp -r \
 docker-compose.yml \
 .env \
 apps \
 packages \
  "$BACKUP" 2>/dev/null || true


echo "Backup created:"
echo "$BACKUP" | tee -a "$REPORT"


echo ""
echo "[2] Scanning Supabase references..."

grep -Rni \
 --exclude-dir=node_modules \
 --exclude-dir=.git \
 "supabase" . \
 >> "$REPORT" 2>/dev/null || true


echo ""
echo "[3] Scanning old EaaS naming..."

grep -Rni \
 --exclude-dir=node_modules \
 --exclude-dir=.git \
 -E "eaas-|EAAS|EaaS" . \
 >> "$REPORT" 2>/dev/null || true


echo ""
echo "[4] Removing Supabase environment references..."

find . \
 -type f \
 ! -path "./node_modules/*" \
 ! -path "./.git/*" \
 -exec sed -i \
 {} + 2>/dev/null || true


echo ""
echo "[5] Standardizing environment variables..."

find . \
 -type f \
 ! -path "./node_modules/*" \
 ! -path "./.git/*" \
 -exec sed -i \
 -e 's/XAASGRID/XAASGRID/g' \
 -e 's/xaasgrid/xaasgrid/g' \
 {} + 2>/dev/null || true


echo ""
echo "[6] Standardizing docker service names..."

find . \
 -name "docker-compose*.yml" \
 -exec sed -i \
 -e 's/xaasgrid-api/xaasgrid-api/g' \
 -e 's/xaasgrid-dashboard/xaasgrid-dashboard/g' \
 -e 's/xaasgrid-postgres/xaasgrid-postgres/g' \
 -e 's/xaasgrid-redis/xaasgrid-redis/g' \
 {} + 2>/dev/null || true


echo ""
echo "[7] Searching remaining legacy references..."

grep -Rni \
 --exclude-dir=node_modules \
 --exclude-dir=.git \
 -E "supabase|eaas-|EAAS" . \
 >> "$REPORT" 2>/dev/null || true


echo ""
echo "===================================="
echo "Phase 1 Completed"
echo "Report:"
echo "$REPORT"
echo "Backup:"
echo "$BACKUP"
echo "===================================="
