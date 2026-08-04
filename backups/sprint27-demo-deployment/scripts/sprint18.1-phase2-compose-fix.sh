#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"

cd "$ROOT"

echo "===================================="
echo "Sprint 18.1 Phase 2 Compose Fix"
echo "$(date)"
echo "===================================="


echo "[1] Backup docker-compose.yml"

cp docker-compose.yml \
docker-compose.yml.phase2-before-dashboard


echo "[2] Writing production compose"


cat > docker-compose.yml <<'EOF'
services:

  xaasgrid-api:
    build:
      context: ./apps/api
    container_name: xaasgrid-api
    ports:
      - "4000:4000"
    env_file:
      - .env
    environment:
      PORT: 4000
      DATABASE_URL: postgresql://eaas_user:EAAS_Strong_2026!@xaasgrid-postgres:5432/eaas_db
      REDIS_URL: redis://xaasgrid-redis:6379
    depends_on:
      xaasgrid-postgres:
        condition: service_started
      xaasgrid-redis:
        condition: service_started
    restart: unless-stopped


  xaasgrid-dashboard:
    build:
      context: ./apps/dashboard
    container_name: xaasgrid-dashboard
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:4000
    depends_on:
      - xaasgrid-api
    restart: unless-stopped


  xaasgrid-postgres:
    image: postgres:15
    container_name: xaasgrid-postgres
    environment:
      POSTGRES_USER: eaas_user
      POSTGRES_PASSWORD: EAAS_Strong_2026!
      POSTGRES_DB: eaas_db
    volumes:
      - infrastructure_postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped


  xaasgrid-redis:
    image: redis:7
    container_name: xaasgrid-redis
    ports:
      - "6379:6379"
    restart: unless-stopped


volumes:

  infrastructure_postgres_data:
    external: true
EOF


echo "[3] Validating compose"

docker compose config


echo "[4] Restarting platform"

docker compose down --remove-orphans

docker compose up -d --build


echo "[5] Container status"

docker ps \
--format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"


echo "===================================="
echo "Phase 2 Compose Fix Complete"
echo "===================================="
