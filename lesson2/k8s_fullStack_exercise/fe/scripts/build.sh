#!/bin/bash

# Build the Docker image
docker build . \
  -t dimrev/l2-react-todo-client:latest \
  -t dimrev/l2-react-todo-client:v0.0.3
