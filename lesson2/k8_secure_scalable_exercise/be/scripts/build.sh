#!/bin/bash

# Build the Docker image
docker build . \
  -t dimrev/l2-py-secure-server:latest \
  -t dimrev/l2-py-secure-server:v0.0.7
