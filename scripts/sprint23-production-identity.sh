#!/bin/bash

set -e

echo "=========================================="
echo "XaaSGrid Sprint 23 Production Identity Activation"
echo "=========================================="

ROOT=/data/eaasgrid-platform
cd $ROOT


echo "[1] Backup Sprint 22 state"

mkdir -p backups/sprint23-production-identity

cp apps/api/src/routes/platform.metrics.js \
backups/sprint23-production-identity/platform.metrics.js.backup 2>/dev/null || true

cp apps/dashboard/app/page.tsx \
backups/sprint23-production-identity/page.tsx.backup 2>/dev/null || true


echo "[2] Validate infrastructure"

docker ps --format "table {{.Names}}\t{{.Status}}"


echo "[3] Create identity seed directory"

mkdir -p apps/api/prisma


echo "[4] Create production identity seed"

cat > apps/api/prisma/sprint23-identity-seed.js <<'EOF'

const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");

const prisma = new PrismaClient();


async function main(){

const passwordHash =
await bcrypt.hash(
"XaaSGridAdmin2026!",
12
);


let user =
await prisma.user.findUnique({
where:{
email:"admin@xaasgrid.com"
}
});


if(!user){

user =
await prisma.user.create({

data:{

email:"admin@xaasgrid.com",

name:
"XaaSGrid Administrator",

passwordHash

}

});

}


console.log(
"Admin user activated:",
user.email
);


}


main()
.then(async()=>{

await prisma.$disconnect();

})
.catch(async(e)=>{

console.error(e);

await prisma.$disconnect();

process.exit(1);

});

EOF


echo "[5] Ensure bcrypt dependency"

docker exec xaasgrid-api sh -c "
cd /app &&
npm list bcryptjs >/dev/null 2>&1 ||
npm install bcryptjs
"


echo "[6] Execute identity seed"

docker exec xaasgrid-api \
node prisma/sprint23-identity-seed.js


echo "[7] Update dashboard metadata"

cat > apps/dashboard/app/layout.tsx <<'EOF'

import type { Metadata } from "next";


export const metadata: Metadata = {

title:
"XaaSGrid Platform",

description:
"Everything-as-a-Service Infrastructure Platform"

};


export default function RootLayout({

children,

}: Readonly<{

children: React.ReactNode

}>) {


return (

<html lang="en">

<body>

{children}

</body>

</html>

);

}

EOF


echo "[8] Clear dashboard cache"

rm -rf apps/dashboard/.next


echo "[9] Rebuild platform"

docker compose build xaasgrid-api xaasgrid-dashboard


echo "[10] Restart platform"

docker compose up -d


echo "[11] Wait for services"

sleep 10


echo "[12] Validate API"

curl -s \
http://localhost:4000/api/health


echo


echo "[13] Validate metrics"

curl -s \
http://localhost:4000/api/platform/metrics


echo


echo "[14] Validate dashboard"

curl -I \
http://localhost:3000


echo

echo "=========================================="
echo "Sprint 23 Production Identity Activation Complete"
echo "=========================================="

echo "Admin:"
echo "admin@xaasgrid.com"

echo "Dashboard:"
echo "XaaSGrid Platform"

echo "=========================================="
