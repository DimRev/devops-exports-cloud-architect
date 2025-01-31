#!/bin/bash

# Build the Docker image
docker build . \
  -t dimrev/l2-redis-client:latest \
  -t dimrev/l2-redis-client:v0.0.2
