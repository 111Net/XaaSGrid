#!/bin/bash

set -e

echo "=========================================="
echo "XaaSGrid Sprint 23 Production Identity Finalizer"
echo "=========================================="

cd /data/eaasgrid-platform

echo "[1] Backup Sprint 22 state"

mkdir -p backups/sprint23-production-identity

cp apps/api/src/routes/platform.metrics.js \
backups/sprint23-production-identity/platform.metrics.js.backup 2>/dev/null || true

cp apps/dashboard/app/page.tsx \
backups/sprint23-production-identity/page.tsx.backup 2>/dev/null || true


echo "[2] Validate infrastructure"

docker ps --format "table {{.Names}}\t{{.Status}}"


echo "[3] Create production identity seed"

mkdir -p apps/api/prisma

cat > apps/api/prisma/sprint23-identity-seed.js <<'EOF'

const prisma = require("../src/database/prisma");
const bcrypt = require("bcrypt");

async function main(){

const existing =
await prisma.user.findUnique({
where:{
email:"admin@xaasgrid.com"
}
});


if(!existing){

const passwordHash =
await bcrypt.hash(
"XaaSGridAdmin2026!",
10
);


await prisma.user.create({

data:{

email:"admin@xaasgrid.com",

passwordHash: passwordHash,

role:"ADMIN"

}

});

console.log("Production admin created");

}

else{

console.log("Production admin already exists");

}


const count =
await prisma.user.count();


console.log(
"Users:",
count
);


}


main()
.catch(err=>{

console.error(err);

process.exit(1);

})
.finally(async()=>{

await prisma.$disconnect();

});

EOF


echo "[4] Ensure bcrypt dependency"

cd apps/api

npm install bcrypt

cd ../..


echo "[5] Rebuild API container with seed included"

docker compose build xaasgrid-api


echo "[6] Restart API"

docker compose up -d xaasgrid-api


echo "[7] Wait for API"

sleep 5


echo "[8] Execute identity seed"

docker exec xaasgrid-api \
node prisma/sprint23-identity-seed.js


echo "[9] Verify metrics API"

curl -s http://localhost:4000/api/platform/metrics


echo


echo "[10] Rebuild dashboard"

docker compose build xaasgrid-dashboard


echo "[11] Restart dashboard"

docker compose up -d xaasgrid-dashboard


echo "[12] Final platform validation"

sleep 5


echo "API Health:"
curl -s http://localhost:4000/api/health


echo


echo "Dashboard:"
curl -I http://localhost:3000 | head -n 1


echo

echo "=========================================="
echo "Sprint 23 Production Identity Finalizer Complete"
echo "=========================================="
