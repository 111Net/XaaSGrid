#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"

echo "=============================================="
echo "XaaSGrid Sprint 20.2 Platform Reconciliation"
echo "$(date)"
echo "=============================================="

cd $ROOT


echo "[1] Creating backup"

mkdir -p backups/sprint20.2-final

cp docker-compose.yml backups/sprint20.2-final/ 2>/dev/null || true
cp .env backups/sprint20.2-final/ 2>/dev/null || true


echo "[2] Removing Supabase runtime dependency"

cd apps/api

npm uninstall @supabase/supabase-js || true

cd $ROOT


echo "[3] Normalizing Prisma"

cat > apps/api/prisma/schema.prisma <<'EOF'

generator client {
 provider = "prisma-client-js"
}


datasource db {
 provider = "postgresql"
 url = env("DATABASE_URL")
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



echo "[4] Repairing Prisma database client"

mkdir -p apps/api/src/database


cat > apps/api/src/database/prisma.js <<'EOF'

const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

module.exports = prisma;

EOF



echo "[5] Renaming old Supabase variables"

find apps/api/src \
-type f \
-name "*.js" \
-exec sed -i \
's/supabase/prisma/g' {} \;


echo "[6] Removing obsolete Supabase config"

rm -f apps/api/src/config/supabase.js || true


echo "[7] Fixing Docker Compose identity"


sed -i '1i name: xaasgrid-platform' docker-compose.yml


sed -i \
's/eaasgrid-platform-xaasgrid-api/xaasgrid-api/g' \
docker-compose.yml


sed -i \
's/eaasgrid-platform-xaasgrid-dashboard/xaasgrid-dashboard/g' \
docker-compose.yml



echo "[8] Updating API Docker build"

cat > apps/api/Dockerfile <<'EOF'

FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npx prisma generate

EXPOSE 4000

CMD ["npm","start"]

EOF



echo "[9] Rebuilding containers"


docker compose down


docker compose build --no-cache


docker compose up -d



echo "[10] Waiting for services"

sleep 15



echo "[11] Container status"

docker ps



echo "[12] API logs"

docker logs --tail 50 xaasgrid-api || true



echo "[13] Prisma validation"

docker compose run --rm xaasgrid-api \
npx prisma validate || true



echo "[14] Database migration"

docker compose run --rm xaasgrid-api \
npx prisma db push || true



echo "[15] Health check"

curl -f http://localhost:4000/api/health || true



echo "=============================================="
echo "Sprint 20.2 reconciliation complete"
echo "=============================================="
