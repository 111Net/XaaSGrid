#!/bin/bash

set -e

echo "=========================================="
echo "Sprint 21 Dashboard Finalizer"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Backup dashboard"
mkdir -p backups/sprint21-finalizer

cp apps/dashboard/app/page.tsx \
backups/sprint21-finalizer/page.tsx.$(date +%s).bak


echo "[2] Verify dashboard page"

if ! grep -q "XaaSGrid Platform" apps/dashboard/app/page.tsx
then

cat > apps/dashboard/app/page.tsx <<'EOF'

import { getMetrics } from "../lib/api";

export default async function Home(){

const metrics = await getMetrics();

return (

<main style={{padding:"40px"}}>

<h1>
XaaSGrid Platform
</h1>

<h2>
Everything-as-a-Service Infrastructure Platform
</h2>


<section>

<h3>
Platform Overview
</h3>


<p>
Users: {metrics.users}
</p>


<p>
Companies: {metrics.companies}
</p>


<p>
Customers: {metrics.customers}
</p>


<p>
Availability: {metrics.availability}
</p>


</section>

</main>

);

}

EOF

fi


echo "[3] Clear Next cache"

rm -rf apps/dashboard/.next


echo "[4] Verify API client"

mkdir -p apps/dashboard/lib


cat > apps/dashboard/lib/api.ts <<'EOF'

const API_URL =
process.env.NEXT_PUBLIC_API_URL ||
"http://192.168.100.21:4000/api";


export async function getMetrics(){

const res = await fetch(
`${API_URL}/v1/platform/metrics`,
{
cache:"no-store"
}
);


if(!res.ok){

throw new Error(
"Metrics API failed"
);

}


return res.json();

}

EOF


echo "[5] Set dashboard environment"

cat > apps/dashboard/.env.production <<EOF

NEXT_PUBLIC_API_URL=http://192.168.100.21:4000/api

EOF



echo "[6] Rebuild dashboard"

docker compose build xaasgrid-dashboard


echo "[7] Restart dashboard"

docker compose up -d xaasgrid-dashboard


echo "[8] Wait"

sleep 10


echo "[9] API test"

curl -s \
http://localhost:4000/api/health


echo


echo "[10] Metrics test"

curl -s \
http://localhost:4000/api/v1/platform/metrics


echo


echo "[11] Dashboard test"

curl -I \
http://localhost:3000


echo

echo "=========================================="
echo "Sprint 21 Dashboard Finalizer Complete"
echo "=========================================="
