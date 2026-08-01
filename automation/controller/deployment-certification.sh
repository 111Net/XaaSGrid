#!/bin/bash

ROOT="/data/eaasgrid-platform"

REPORT="$ROOT/automation/reports/sprint18.1/deployment-certification.txt"

mkdir -p "$(dirname $REPORT)"

PASS=0
TOTAL=0


echo "====================================" > $REPORT
echo " XaaSGrid Deployment Certification" >> $REPORT
echo " Sprint 18.1 Final Gate" >> $REPORT
echo "====================================" >> $REPORT

date >> $REPORT


check()
{

NAME=$1
COMMAND=$2


TOTAL=$((TOTAL+1))


echo "" >> $REPORT
echo "Checking $NAME" >> $REPORT


if eval "$COMMAND"
then

echo "$NAME : PASS" >> $REPORT
PASS=$((PASS+1))

else

echo "$NAME : FAILED" >> $REPORT

fi

}



check \
"Repository Structure" \
"test -d $ROOT/apps && test -d $ROOT/automation"


check \
"Docker Available" \
"docker info >/dev/null 2>&1"


check \
"Docker Compose" \
"docker compose version >/dev/null 2>&1"


check \
"API Health" \
"curl -sf http://localhost:4000/api/health >/dev/null || curl -sf http://localhost:4100/api/health >/dev/null"


check \
"Dashboard" \
"curl -sf http://localhost:3000 >/dev/null"


check \
"Guardian Framework" \
"test -d $ROOT/scripts/guardian"


check \
"Module Framework" \
"test -d $ROOT/automation/modules"


check \
"Bootstrap Available" \
"test -x $ROOT/bootstrap.sh"


PERCENT=$((PASS*100/TOTAL))


echo "" >> $REPORT
echo "====================================" >> $REPORT
echo "CERTIFICATION SCORE: $PERCENT%" >> $REPORT
echo "====================================" >> $REPORT


if [ $PERCENT -ge 90 ]
then

echo "STATUS: CERTIFIED" >> $REPORT

else

echo "STATUS: NOT CERTIFIED" >> $REPORT

fi


cat $REPORT
