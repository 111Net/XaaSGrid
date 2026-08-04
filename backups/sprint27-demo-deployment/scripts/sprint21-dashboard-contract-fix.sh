#!/bin/bash

set -e

echo "=========================================="
echo "Sprint 21 Dashboard Contract Fix"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Backup dashboard files"

mkdir -p backups/sprint21-contract-fix

cp apps/dashboard/lib/api.ts \
backups/sprint21-contract-fix/api.ts.bak || true

cp apps/dashboard/app/page.tsx \
backups/sprint21-contract-fix/page.tsx.bak || true



echo "[2] Fix API client contract"

cat > apps/dashboard/lib/api.ts <<'EOF'

const API_URL =
process.env.NEXT_PUBLIC_API_URL ||
"http://192.168.100.21:4000/api";


export async function getPlatformMetrics(){

const response = await fetch(
`${API_URL}/v1/platform/metrics`,
{
cache:"no-store"
}
);


if(!response.ok){

throw new Error(
"Platform metrics request failed"
);

}


return response.json();

}

EOF



echo "[3] Fix dashboard page import"

sed -i \
's/getMetrics/getPlatformMetrics/g' \
apps/dashboard/app/page.tsx



echo "[4] Remove Next cache"

rm -rf apps/dashboard/.next



echo "[5] Rebuild dashboard"

docker compose build xaasgrid-dashboard



echo "[6] Restart dashboard"

docker compose up -d xaasgrid-dashboard



echo "[7] Wait"

sleep 10



echo "[8] Dashboard HTTP test"

curl -I http://localhost:3000



echo


echo "[9] API metrics test"

curl http://localhost:4000/api/v1/platform/metrics



echo


echo "=========================================="
echo "Sprint 21 Dashboard Contract Fix Complete"
echo "=========================================="
