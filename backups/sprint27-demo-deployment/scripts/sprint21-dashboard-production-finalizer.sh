#!/bin/bash

set -e

echo "=========================================="
echo "Sprint 21 Dashboard Production Finalizer"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Backup dashboard"

mkdir -p backups/sprint21-final

cp apps/dashboard/lib/api.ts \
backups/sprint21-final/api.ts.backup 2>/dev/null || true

cp apps/dashboard/app/page.tsx \
backups/sprint21-final/page.tsx.backup 2>/dev/null || true


echo "[2] Fix Docker internal API endpoint"


cat > apps/dashboard/lib/api.ts <<'EOF'

const API_URL =
process.env.INTERNAL_API_URL ||
"http://xaasgrid-api:4000";


export async function getPlatformMetrics(){

    const response = await fetch(
        `${API_URL}/api/platform/metrics`,
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


echo "[3] Make dashboard resilient"


cat > apps/dashboard/app/page.tsx <<'EOF'

import { getPlatformMetrics } from "../lib/api";


export default async function Home(){

let metrics:any = {
    platform:"XaaSGrid",
    users:0,
    companies:0,
    customers:0,
    auditEvents:0,
    availability:"unknown"
};


try {

metrics = await getPlatformMetrics();

}
catch(error){

console.error(
"Metrics unavailable",
error
);

}


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
Audit Events: {metrics.auditEvents || 0}
</p>


<p>
Availability: {metrics.availability}
</p>


</section>


</main>

);

}

EOF


echo "[4] Remove Next cache"

rm -rf apps/dashboard/.next


echo "[5] Rebuild containers"

docker compose build xaasgrid-dashboard


echo "[6] Restart dashboard"

docker compose up -d xaasgrid-dashboard


echo "[7] Wait"

sleep 10


echo "[8] Dashboard test"

curl -I http://localhost:3000


echo "[9] API test"

curl http://localhost:4000/api/platform/metrics


echo "=========================================="
echo "Sprint 21 Dashboard Production Finalizer Complete"
echo "=========================================="
