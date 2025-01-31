#!/bin/bash

echo "Building and running multi-stage-build container..."

docker build . \
  -t dimrev/multi-stage-build:latest \
  -t dimrev/multi-stage-build:v0.0.0

echo "Running multi-stage-build container..."

docker run --name msb-exercise -d -p 3000:3000 dimrev/multi-stage-build:latest

echo "Waiting for multi-stage-build container to start..."
sleep 5
echo "Testing multi-stage-build container..."
curl http://localhost:3000