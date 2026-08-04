#!/bin/bash

set -e

echo "=========================================="
echo "XaaSGrid Sprint 21 Live Dashboard"
echo "Integration Automation"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Creating backup"

mkdir -p backups/sprint21-live-dashboard

cp apps/dashboard/app/page.tsx \
backups/sprint21-live-dashboard/page.tsx.backup 2>/dev/null || true

cp apps/api/src/routes/platform.metrics.js \
backups/sprint21-live-dashboard/platform.metrics.js.backup 2>/dev/null || true


echo "[2] Updating platform metrics API"


cat > apps/api/src/routes/platform.metrics.js <<'EOF'

const express = require("express");
const router = express.Router();

const prisma = require("../database/prisma");


router.get("/metrics", async (req,res)=>{

try {

const users =
await prisma.user.count();

const companies =
await prisma.company.count();

const customers =
await prisma.customer.count();

const auditEvents =
await prisma.auditLog.count();


res.json({

success:true,

platform:"XaaSGrid",

users,

companies,

customers,

auditEvents,

availability:"100%",

timestamp:new Date().toISOString()

});


}

catch(error){

res.status(500).json({

success:false,

error:error.message

});

}

});


module.exports = router;

EOF


echo "[3] Creating dashboard API client"


mkdir -p apps/dashboard/lib


cat > apps/dashboard/lib/api.ts <<'EOF'

const API_URL =
process.env.NEXT_PUBLIC_API_URL ||
"http://localhost:4000/api";


export async function getPlatformMetrics(){

const response =
await fetch(
`${API_URL}/platform/metrics`,
{
cache:"no-store"
}
);


if(!response.ok){

throw new Error(
"Unable to retrieve platform metrics"
);

}


return response.json();

}

EOF



echo "[4] Updating dashboard homepage"


cat > apps/dashboard/app/page.tsx <<'EOF'

import { getPlatformMetrics } from "../lib/api";


export default async function Home(){


const metrics =
await getPlatformMetrics();



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
Audit Events: {metrics.auditEvents}
</p>


<p>
Availability: {metrics.availability}
</p>


</section>


</main>

);


}

EOF



echo "[5] Updating dashboard environment"

if [ ! -f apps/dashboard/.env ]; then

cat > apps/dashboard/.env <<'EOF'

NEXT_PUBLIC_API_URL=http://localhost:4000/api

EOF

fi



echo "[6] Building containers"


docker compose build xaasgrid-api xaasgrid-dashboard



echo "[7] Restarting platform"


docker compose up -d



echo "[8] Waiting for services"

sleep 10



echo "[9] API health test"

curl -f \
http://localhost:4000/api/health


echo


echo "[10] Metrics API test"

curl -f \
http://localhost:4000/api/platform/metrics


echo


echo "[11] Dashboard test"

curl -I \
http://localhost:3000



echo
echo "=========================================="
echo "Sprint 21 Live Dashboard Complete"
echo "=========================================="
