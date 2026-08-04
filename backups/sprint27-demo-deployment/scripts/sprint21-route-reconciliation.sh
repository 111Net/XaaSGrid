#!/bin/bash

set -e

echo "=========================================="
echo "Sprint 21 Route Reconciliation"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Backup"

mkdir -p backups/sprint21-route

cp apps/api/src/app.js backups/sprint21-route/app.js.bak
cp apps/api/src/routes/index.js backups/sprint21-route/index.js.bak
cp apps/dashboard/lib/api.ts backups/sprint21-route/api.ts.bak



echo "[2] Normalize API route"

python3 <<'PY'

from pathlib import Path

p=Path("apps/api/src/app.js")

x=p.read_text()

x=x.replace(
'app.use(\n    "/api/v1",\n    routes\n);',
'app.use(\n    "/api",\n    routes\n);'
)

p.write_text(x)

PY



echo "[3] Normalize dashboard API client"


cat > apps/dashboard/lib/api.ts <<'EOF'

const API_URL =
process.env.NEXT_PUBLIC_API_URL ||
"http://192.168.100.21:4000/api";


export async function getPlatformMetrics(){

const response = await fetch(
`${API_URL}/platform/metrics`,
{
cache:"no-store"
}
);


if(!response.ok){

throw new Error(
"Platform metrics API failed"
);

}


return response.json();

}

EOF



echo "[4] Clear cache"

rm -rf apps/dashboard/.next



echo "[5] Rebuild"

docker compose build xaasgrid-api xaasgrid-dashboard



echo "[6] Restart"

docker compose up -d



echo "[7] Wait"

sleep 10



echo "[8] API health"

curl http://localhost:4000/api/health


echo


echo "[9] Metrics"

curl http://localhost:4000/api/platform/metrics


echo


echo "[10] Dashboard"

curl -I http://localhost:3000


echo

echo "=========================================="
echo "Sprint 21 Route Reconciliation Complete"
echo "=========================================="
