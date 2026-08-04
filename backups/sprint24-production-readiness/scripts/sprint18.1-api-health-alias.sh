#!/bin/bash

set -e

ROOT="/data/eaasgrid-platform"

cd "$ROOT"

echo "===================================="
echo "Sprint 18.1 API Health Alias"
echo "$(date)"
echo "===================================="


echo "[1] Backup app.js"

cp apps/api/src/app.js \
apps/api/src/app.js.phase18-backup


echo "[2] Adding /api/health route"


python3 <<'PY'

from pathlib import Path

p = Path("apps/api/src/app.js")

text = p.read_text()

marker = 'app.use(\n    "/api/v1",\n    routes\n);'

replacement = '''
app.get("/api/health", (req,res)=>{

    res.json({

        status:"ok",

        service:"XaaSGrid API",

        timestamp:new Date().toISOString()

    });

});


app.use(
    "/api/v1",
    routes
);
'''

if marker not in text:
    raise Exception("Route insertion point not found")

text=text.replace(marker,replacement)

p.write_text(text)

PY


echo "[3] Rebuild API"

docker compose build xaasgrid-api


echo "[4] Restart API"

docker compose up -d xaasgrid-api


echo "[5] Testing"

curl http://localhost:4000/api/health


echo ""
echo "===================================="
echo "Health alias completed"
echo "===================================="
