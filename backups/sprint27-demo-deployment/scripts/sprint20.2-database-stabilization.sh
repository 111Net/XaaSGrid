#!/bin/bash

set -e

echo "=============================================="
echo "XaaSGrid Sprint 20.2 Database Stabilization"
echo "$(date)"
echo "=============================================="


ROOT="/data/eaasgrid-platform"
API="$ROOT/apps/api"

cd "$ROOT"


echo "[1] Backup Sprint 20.1 state"

mkdir -p backups/sprint20.2

cp -r "$API/src" backups/sprint20.2/api-src-backup


echo "[2] Downgrade Prisma to production version"

cd "$API"

npm uninstall prisma @prisma/client

npm install prisma@6 @prisma/client@6


echo "[3] Generate Prisma client"

npx prisma generate


echo "[4] Create Prisma database client"

mkdir -p src/database

cat > src/database/prisma.js <<'EOF'
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

module.exports = prisma;
EOF


echo "[5] Remove remaining Supabase runtime references"

find src \
-type f \
-not -name "*.backup" \
-exec sed -i \
's/require(\"..\/config\/database\")/require(\"..\/database\/prisma\")/g' {} \;


find src \
-type f \
-not -name "*.backup" \
-exec sed -i \
's/require(\"..\/config\/supabase\")/require(\"..\/database\/prisma\")/g' {} \;


echo "[6] Update package validation"

grep -R "supabase\|@supabase" src -n || true


echo "[7] Create database schema"

cat > prisma/schema.prisma <<'EOF'

generator client {
 provider = "prisma-client-js"
}


datasource db {
 provider = "postgresql"
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


model Customer {

 id Int @id @default(autoincrement())

 name String

 email String @unique

 createdAt DateTime @default(now())

}


model AuditLog {

 id Int @id @default(autoincrement())

 action String

 createdAt DateTime @default(now())

}

EOF


echo "[8] Prisma validation"

npx prisma validate


echo "[9] Rebuild containers"

cd "$ROOT"

docker compose build

docker compose up -d


echo "[10] Wait for API"

sleep 10


echo "[11] API Health"

curl -f http://localhost:4000/api/health


echo


echo "[12] Database check"

docker exec xaasgrid-postgres \
psql -U eaas_user -d eaas_db \
-c "\dt"


echo "[13] Redis check"

docker exec xaasgrid-redis redis-cli ping


echo "[14] Dashboard check"

curl -f http://localhost:3000


echo


echo "=============================================="
echo "Sprint 20.2 Stabilization Complete"
echo "=============================================="
