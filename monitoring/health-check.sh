
#!/bin/bash


echo "XaaSGrid Health Check"


curl -sf http://localhost:4000/api/health

echo

curl -I http://localhost:3000 | head -n 1


docker compose ps

