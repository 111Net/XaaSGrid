#!/bin/bash

set -e

echo "=========================================="
echo "XaaSGrid Sprint 22 Finalizer"
echo "Live Database Activation Completion"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Backup current Sprint 22 state"

mkdir -p backups/sprint22-finalizer

cp apps/api/src/routes/platform.metrics.js \
backups/sprint22-finalizer/platform.metrics.js.backup 2>/dev/null || true


echo "[2] Verify infrastructure"

docker ps --format "table {{.Names}}\t{{.Status}}"


echo "[3] Create database seed"

mkdir -p apps/api/prisma


cat > apps/api/prisma/sprint22-seed.js <<'EOF'

const prisma = require("../src/database/prisma");

async function main(){

    console.log("Starting Sprint 22 seed");

    const admin =
    await prisma.user.create({
        data:{
            email:"admin@xaasgrid.com",
            name:"XaaSGrid Administrator"
        }
    }).catch(e=>null);


    const company =
    await prisma.company.create({
        data:{
            name:"XaaSGrid Demo Company"
        }
    }).catch(e=>null);


    const customer =
    await prisma.customer.create({
        data:{
            name:"Demo Customer"
        }
    }).catch(e=>null);


    const audit =
    await prisma.auditLog.create({
        data:{
            action:"SPRINT22_DATABASE_ACTIVATION"
        }
    }).catch(e=>null);


    console.log({
        admin,
        company,
        customer,
        audit
    });

}


main()
.then(async()=>{
    await prisma.$disconnect();
})
.catch(async(error)=>{
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
});

EOF


echo "[4] Execute database seed"

docker exec xaasgrid-api \
node prisma/sprint22-seed.js


echo "[5] Update metrics verification"

curl -s http://localhost:4000/api/platform/metrics


echo


echo "[6] Rebuild platform"

docker compose build xaasgrid-api xaasgrid-dashboard


echo "[7] Restart platform"

docker compose up -d


echo "[8] Wait for services"

sleep 10


echo "[9] Health test"

curl -s http://localhost:4000/api/health


echo


echo "[10] Metrics test"

curl -s http://localhost:4000/api/platform/metrics


echo


echo "[11] Dashboard test"

curl -I http://localhost:3000 | head -n 1


echo


echo "=========================================="
echo "Sprint 22 Finalizer Complete"
echo "=========================================="
