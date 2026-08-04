#!/bin/bash

set +e

ROOT="/data/eaasgrid-platform"
REPORT="$ROOT/sprint18.1-production-certification-report.txt"

cd "$ROOT"

echo "====================================" | tee $REPORT
echo "XaaSGrid Sprint 18.1 Production Certification" | tee -a $REPORT
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
echo "Docker Containers" | tee -a $REPORT

for c in xaasgrid-api xaasgrid-dashboard xaasgrid-postgres xaasgrid-redis
do
docker ps --format '{{.Names}}' | grep -q $c

if [ $? -eq 0 ]; then
pass "$c running"
else
fail "$c missing"
fi

done


echo "" | tee -a $REPORT
echo "PostgreSQL" | tee -a $REPORT

docker exec xaasgrid-postgres \
psql -U eaas_user -d eaas_db -c "\q" >/dev/null 2>&1

if [ $? -eq 0 ]; then
pass "PostgreSQL eaas_db accessible"
else
fail "PostgreSQL unavailable"
fi


echo "" | tee -a $REPORT
echo "Redis" | tee -a $REPORT

REDIS=$(docker exec xaasgrid-redis redis-cli ping)

if [ "$REDIS" = "PONG" ]; then
pass "Redis responding"
else
fail "Redis failed"
fi


echo "" | tee -a $REPORT
echo "API" | tee -a $REPORT

curl -s http://localhost:4000/api/health | grep -q '"status":"ok"'

if [ $? -eq 0 ]; then
pass "API health endpoint"
else
fail "API health failed"
fi


echo "" | tee -a $REPORT
echo "Dashboard" | tee -a $REPORT

curl -s http://localhost:3000 | grep -q "XaaSGrid"

if [ $? -eq 0 ]; then
pass "Dashboard accessible"
else
fail "Dashboard unavailable"
fi


echo "" | tee -a $REPORT
echo "Environment" | tee -a $REPORT

if grep -q JWT_SECRET .env; then
pass "JWT_SECRET configured"
else
warn "JWT_SECRET not found in root .env"
fi


echo "" | tee -a $REPORT
echo "Prisma" | tee -a $REPORT

find . -name schema.prisma | grep -q schema.prisma

if [ $? -eq 0 ]; then
pass "Prisma schema found"
else
warn "Prisma schema not found"
fi


echo "" | tee -a $REPORT
echo "Systemd" | tee -a $REPORT

systemctl is-enabled xaasgrid-api.service >/dev/null 2>&1

if [ $? -eq 0 ]; then
pass "xaasgrid-api systemd enabled"
else
warn "xaasgrid-api systemd missing"
fi


systemctl list-unit-files | grep -q xaasgrid-orchestrator

if [ $? -eq 0 ]; then
warn "xaasgrid-orchestrator exists but requires review"
fi


echo "" | tee -a $REPORT
echo "Guardian" | tee -a $REPORT

if [ -d scripts/guardian ]; then
pass "Guardian framework present"
else
warn "Guardian framework missing"
fi


echo "" | tee -a $REPORT
echo "====================================" | tee -a $REPORT
echo "Certification Complete" | tee -a $REPORT
echo "Report: $REPORT" | tee -a $REPORT
echo "====================================" | tee -a $REPORT
