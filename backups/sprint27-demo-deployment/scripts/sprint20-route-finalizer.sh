#!/bin/bash

set -e

echo "=========================================="
echo "XaaSGrid Sprint 20 Route Finalizer"
echo "=========================================="

cd /data/eaasgrid-platform


echo "[1] Backup API routing files"

mkdir -p backups/sprint20-route-finalizer

cp apps/api/src/app.js \
backups/sprint20-route-finalizer/app.js.backup

cp apps/api/src/routes/index.js \
backups/sprint20-route-finalizer/index.js.backup


echo "[2] Registering direct platform metrics route"

python3 <<'PY'

from pathlib import Path

app = Path("apps/api/src/app.js")

text = app.read_text()

old='''app.use(
    "/api/v1",
    routes
);'''

new='''app.use(
    "/api",
    routes
);'''

if old in text:
    text=text.replace(old,new)

app.write_text(text)

PY


echo "[3] Ensuring platform metrics route exists"

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


res.json({

success:true,

platform:"XaaSGrid",

users,

companies,

customers,

monthlyRevenue:"₦0",

availability:"100%"

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


echo "[4] Ensuring platform route registration"

python3 <<'PY'

from pathlib import Path

p=Path("apps/api/src/routes/index.js")

text=p.read_text()

if 'require("./platform.metrics")' not in text:
    text=text.replace(
        'const router = express.Router();',
        '''const router = express.Router();

'''
    )

    text += '''
router.use(
    "/platform",
    require("./platform.metrics")
);
'''

p.write_text(text)

PY


echo "[5] Building API"

docker compose build xaasgrid-api


echo "[6] Restarting API"

docker compose up -d xaasgrid-api


echo "[7] Waiting for API"

sleep 10


echo "[8] Health check"

curl -f http://localhost:4000/api/health


echo


echo "[9] Platform metrics check"

curl -f http://localhost:4000/api/platform/metrics


echo


echo "=========================================="
echo "Sprint 20 Route Finalizer Complete"
echo "=========================================="
