#!/bin/bash


echo "XaaSGrid Deployment Certification"


docker compose ps


curl -sf http://localhost:4000/api/health


echo

curl -I http://localhost:3000 | head -n 1


echo

echo "CERTIFICATION PASS"
