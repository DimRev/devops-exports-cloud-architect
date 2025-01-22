#!/bin/bash
echo "Building custom docker image..."

docker build . \
  -t dimrev/custom-docker-image:latest \
  -t dimrev/custom-docker-image:v0.0.0

echo "Running custom docker image..."
docker run --name cdi-exercise -d -p 8080:80 dimrev/custom-docker-image:latest

echo "Waiting for custom docker image to start..."
sleep 5

curl http://localhost:8080