#!/bin/bash

set -e

echo "================================="
echo "XaaSGrid Universal Installer"
echo "================================="


if ! command -v docker >/dev/null
then
    echo "Docker not installed"
    exit 1
fi


if ! docker compose version >/dev/null
then
    echo "Docker Compose missing"
    exit 1
fi


echo "Docker validated"


if [ ! -d .git ]
then
    echo "Repository missing"
    exit 1
fi


echo "Repository validated"


echo "Starting XaaSGrid"

docker compose up -d


sleep 10


echo "Checking API"

curl -sf http://localhost:4000/api/health


echo

echo "Checking Dashboard"

curl -I http://localhost:3000 | head -n 1


echo

echo "================================="
echo "XaaSGrid Installation Successful"
echo "================================="

echo "Dashboard:"
echo "http://SERVER-IP:3000"

echo "API:"
echo "http://SERVER-IP:4000"
