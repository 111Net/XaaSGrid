#!/bin/bash

set -e

cd /data/eaasgrid-platform

echo "===================================="
echo "Sprint 18.1 API Health Cleanup"
echo "$(date)"
echo "===================================="


echo "[1] Backup app.js"

cp apps/api/src/app.js \
apps/api/src/app.js.health-cleanup-backup


echo "[2] Removing duplicate health route"

python3 <<'PY'

from pathlib import Path

p = Path("apps/api/src/app.js")

text = p.read_text()

block = '''
app.get("/api/health", (req,res)=>{

    res.json({

        status:"ok",

        service:"XaaSGrid API",

        timestamp:new Date().toISOString()

    });

});


'''

first = text.find(block)
second = text.find(block, first + 1)

if second != -1:
    text = text[:second] + text[second+len(block):]

p.write_text(text)

PY


echo "[3] Rebuild API"

docker compose build xaasgrid-api


echo "[4] Restart API"

docker compose up -d xaasgrid-api


echo "[5] Test /api/health"

sleep 3

curl -i http://localhost:4000/api/health


echo ""
echo "===================================="
echo "Completed"
echo "===================================="
