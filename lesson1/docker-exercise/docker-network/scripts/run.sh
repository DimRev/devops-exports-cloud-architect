#!/bin/bash

set -e

echo "Running the docker-compose file"

docker-compose up -d

# Ping the from web to the db container
docker exec -it web ping -c 1 db

# Ping the from web to backend container
docker exec -it web ping -c 1 backend

# Ping the from backend to the db container
docker exec -it backend ping -c 1 db

# Ping the from backend to the web container
docker exec -it backend ping -c 1 web

# Ping the from db to the web container
docker exec -it db ping -c 1 web

# Ping the from db to the backend container
docker exec -it db ping -c 1 backend

docker-compose down