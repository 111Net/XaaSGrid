#!/bin/bash

set -e

echo "=========================================="
echo "XaaSGrid Sprint 31 Prisma Reconciliation"
echo "Schema Duplicate Cleanup"
echo "=========================================="

ROOT=/data/eaasgrid-platform

cd $ROOT


SCHEMA="apps/api/prisma/schema.prisma"


echo "[1] Backup current schema"

mkdir -p backups/sprint31-prisma-reconciliation

cp $SCHEMA \
backups/sprint31-prisma-reconciliation/schema.before-cleanup.$(date +%Y%m%d-%H%M%S).prisma



echo "[2] Check duplicates"

echo "Subscription:"
grep -n "^model Subscription" $SCHEMA || true

echo

echo "Invoice:"
grep -n "^model Invoice" $SCHEMA || true

echo

echo "CustomerUser:"
grep -n "^model CustomerUser" $SCHEMA || true



echo "[3] Remove duplicate model blocks"


python3 <<'PY'

from pathlib import Path

schema = Path("apps/api/prisma/schema.prisma")

text = schema.read_text()


models = [
    "Subscription",
    "Invoice",
    "CustomerUser"
]


def keep_first_model(content, model):

    marker=f"model {model} {{"

    positions=[]

    start=0

    while True:

        pos=content.find(marker,start)

        if pos==-1:
            break

        positions.append(pos)

        start=pos+1


    if len(positions)<=1:
        return content


    print(model,"found",len(positions),"copies")


    # keep first
    remove=[]


    for pos in positions[1:]:

        end=content.find("\n}",pos)

        if end!=-1:
            remove.append((pos,end+3))


    for a,b in reversed(remove):

        content=content[:a]+content[b:]


    return content



for m in models:

    text=keep_first_model(text,m)



schema.write_text(text)


PY



echo "[4] Verify duplicates"

grep -n "^model Subscription" $SCHEMA || true

grep -n "^model Invoice" $SCHEMA || true

grep -n "^model CustomerUser" $SCHEMA || true



echo "[5] Prisma validation"


cd apps/api


npx prisma validate


echo


echo "[6] Generate Prisma client"


npx prisma generate


cd ../..



echo "[7] Rebuild API"


docker compose build --no-cache xaasgrid-api



echo "[8] Restart API"


docker compose up -d xaasgrid-api



sleep 10



echo "[9] API verification"


curl -s http://localhost:4000/api/health


echo


echo "=========================================="
echo "Sprint 31 Prisma Reconciliation Complete"
echo "=========================================="
