#!/bin/bash

set -e

echo "===================================="
echo "Sprint 20.1 Supabase Removal Prisma Migration"
date
echo "===================================="


cd /data/eaasgrid-platform


echo "[1] Backup Supabase code"

mkdir -p backups/sprint20.1

cp -r apps/api/src/config/supabase.js \
backups/sprint20.1/ 2>/dev/null || true


cp -r apps/api/src/services \
backups/sprint20.1/services-backup


cp -r apps/api/src/controllers \
backups/sprint20.1/controllers-backup


echo "[2] Removing Supabase config"

rm -f apps/api/src/config/supabase.js


echo "[3] Creating Prisma database client"

mkdir -p apps/api/src/database


cat > apps/api/src/database/prisma.js <<EOF
const {PrismaClient}=require("@prisma/client");

const prisma=new PrismaClient();

module.exports=prisma;
EOF


echo "[4] Replacing company service"


cat > apps/api/src/services/company.service.js <<EOF

const prisma=require("../database/prisma");


async function getCompanies(){

return prisma.company.findMany();

}


module.exports={
getCompanies
};

EOF


echo "[5] Creating Prisma models"

cat > apps/api/prisma/schema.prisma <<EOF

generator client {
 provider="prisma-client-js"
}


datasource db {
 provider="postgresql"
 url=env("DATABASE_URL")
}


model User {

 id Int @id @default(autoincrement())

 email String @unique

 passwordHash String

 role String @default("user")

 createdAt DateTime @default(now())

}


model Company {

 id Int @id @default(autoincrement())

 name String

 createdAt DateTime @default(now())

}

EOF


echo "[6] Generate Prisma client"

cd apps/api

npx prisma generate


echo "[7] Create database tables"

npx prisma db push


echo "[8] Fix auth route"

cd ../..

sed -i 's#"/api/auth"#"/api/v1/auth"#' apps/api/src/app.js


echo "[9] Rebuild containers"

docker compose build xaasgrid-api

docker compose up -d


echo "[10] Test API"

sleep 5

curl http://localhost:4000/api/health


echo
echo "===================================="
echo "Sprint 20.1 Completed"
echo "===================================="
