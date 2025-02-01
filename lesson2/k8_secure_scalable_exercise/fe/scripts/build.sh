#!/bin/bash

# Build the Docker image
docker build . \
  -t dimrev/l2-react-secure-client:latest \
  -t dimrev/l2-react-secure-client:v0.0.4
