#!/bin/bash

set +e

ROOT="/data/eaasgrid-platform"
REPORT="$ROOT/sprint18.1-production-certification-v2-report.txt"

cd "$ROOT"

echo "====================================" | tee $REPORT
echo "XaaSGrid Sprint 18.1 Final Certification v2" | tee -a $REPORT
echo "$(date)" | tee -a $REPORT
echo "====================================" | tee -a $REPORT


pass()
{
echo "[PASS] $1" | tee -a $REPORT
}

warn()
{
echo "[WARN] $1" | tee -a $REPORT
}

fail()
{
echo "[FAIL] $1" | tee -a $REPORT
}


echo "" | tee -a $REPORT
echo "1. Docker Foundation" | tee -a $REPORT


for c in xaasgrid-api xaasgrid-dashboard xaasgrid-postgres xaasgrid-redis
do

docker ps --format '{{.Names}}' | grep -q "^$c$"

if [ $? -eq 0 ]; then
pass "$c running"
else
fail "$c missing"
fi

done



echo "" | tee -a $REPORT
echo "2. Browser Dashboard Validation" | tee -a $REPORT


PAGE=$(curl -s http://localhost:3000)


echo "$PAGE" | grep -q "XaaSGrid"

if [ $? -eq 0 ]; then
pass "Dashboard contains XaaSGrid branding"
else
fail "Dashboard branding missing"
fi



echo "" | tee -a $REPORT
echo "3. API Validation" | tee -a $REPORT


curl -s http://localhost:4000/api/health | grep -q '"status":"ok"'

if [ $? -eq 0 ]; then
pass "/api/health"
else
fail "/api/health unavailable"
fi


curl -s http://localhost:4000/api/v1/health | grep -q '"status":"ok"'

if [ $? -eq 0 ]; then
pass "/api/v1/health"
else
fail "/api/v1/health unavailable"
fi



echo "" | tee -a $REPORT
echo "4. Database Validation" | tee -a $REPORT


docker exec xaasgrid-postgres \
psql -U eaas_user -d eaas_db -c "\q" >/dev/null 2>&1


if [ $? -eq 0 ]; then
pass "PostgreSQL eaas_db"
else
fail "PostgreSQL failed"
fi



echo "" | tee -a $REPORT
echo "5. Redis Validation" | tee -a $REPORT


if [ "$(docker exec xaasgrid-redis redis-cli ping)" = "PONG" ]; then
pass "Redis responding"
else
fail "Redis unavailable"
fi



echo "" | tee -a $REPORT
echo "6. Authentication Readiness" | tee -a $REPORT


grep -R "auth\|jwt\|token\|bcrypt\|password" apps/api/src -n >/dev/null 2>&1


if [ $? -eq 0 ]; then
pass "Authentication code detected"
else
warn "Authentication module not implemented"
fi



echo "" | tee -a $REPORT
echo "7. Demo Data Readiness" | tee -a $REPORT


grep -R "mock\|demo\|sample\|seed" apps/dashboard apps/api -n >/dev/null 2>&1


if [ $? -eq 0 ]; then
pass "Demo/sample data detected"
else
warn "Demo data not detected"
fi



echo "" | tee -a $REPORT
echo "8. Prisma" | tee -a $REPORT


find . -name schema.prisma | grep -q schema.prisma


if [ $? -eq 0 ]; then
pass "Prisma schema detected"
else
warn "Prisma schema missing"
fi



echo "" | tee -a $REPORT
echo "9. Systemd" | tee -a $REPORT


systemctl is-enabled xaasgrid-api.service >/dev/null 2>&1

if [ $? -eq 0 ]; then
pass "xaasgrid-api.service enabled"
else
warn "xaasgrid-api.service not enabled"
fi



echo "" | tee -a $REPORT
echo "10. Guardian Framework" | tee -a $REPORT


if [ -d scripts/guardian ]; then
pass "Guardian framework available"
else
warn "Guardian missing"
fi



echo "" | tee -a $REPORT
echo "11. Restart Resilience Test" | tee -a $REPORT


docker compose restart >/dev/null 2>&1

sleep 10


COUNT=$(docker ps --format '{{.Names}}' | grep -c xaasgrid)


if [ "$COUNT" -eq 4 ]; then
pass "All services survived restart"
else
fail "Restart validation failed"
fi



echo "" | tee -a $REPORT
echo "====================================" | tee -a $REPORT
echo "Final Certification Complete" | tee -a $REPORT
echo "Report: $REPORT" | tee -a $REPORT
echo "====================================" | tee -a $REPORT
