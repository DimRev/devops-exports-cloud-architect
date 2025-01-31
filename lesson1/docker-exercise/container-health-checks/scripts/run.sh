#!/bin/bash

echo "Building container-health-check image..."

docker build . \
  -t dimrev/container-health-check:latest \
  -t dimrev/container-health-check:v0.0.0

echo "Running container-health-check container..."

docker run -d --name chc-exercise -p 5000:5000 dimrev/container-health-check:latest