#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"
REPORT="$ROOT/sprint18.1-phase3-4-validation-report.txt"

cd "$ROOT"

echo "====================================" | tee "$REPORT"
echo "Sprint 18.1 Phase 3-4 Validation" | tee -a "$REPORT"
echo "$(date)" | tee -a "$REPORT"
echo "====================================" | tee -a "$REPORT"


echo ""
echo "[1] Docker containers"

docker ps \
--format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
| tee -a "$REPORT"


echo ""
echo "[2] PostgreSQL database validation"

docker exec -i xaasgrid-postgres \
psql -U eaas_user -d eaas_db \
-c "\l" \
| tee -a "$REPORT"


echo ""
echo "[3] PostgreSQL user validation"

docker exec -i xaasgrid-postgres \
psql -U eaas_user -d eaas_db \
-c "\du" \
| tee -a "$REPORT"


echo ""
echo "[4] Redis validation"

docker exec xaasgrid-redis redis-cli ping \
| tee -a "$REPORT"


echo ""
echo "[5] Prisma validation"

if [ -d apps/api/prisma ]; then

 echo "Prisma directory found" | tee -a "$REPORT"

 find apps/api/prisma -maxdepth 2 -type f \
 | tee -a "$REPORT"

else

 echo "WARNING: Prisma directory not found under apps/api" \
 | tee -a "$REPORT"

fi


echo ""
echo "[6] API health validation"

curl -s \
http://localhost:4000/api/v1/health \
| tee -a "$REPORT"


echo ""
echo ""
echo "===================================="
echo "Validation Complete"
echo "Report:"
echo "$REPORT"
echo "===================================="
