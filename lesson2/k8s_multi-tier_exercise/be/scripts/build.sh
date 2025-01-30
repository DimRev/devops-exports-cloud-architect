#!/bin/bash

# Build the Docker image
docker build . \
  -t dimrev/l2-py-redis-server:latest \
  -t dimrev/l2-py-redis-server:v0.0.3
