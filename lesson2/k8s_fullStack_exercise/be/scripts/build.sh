#!/bin/bash

# Build the Docker image
docker build . \
  -t dimrev/l2-py-todo-server:latest \
  -t dimrev/l2-py-todo-server:v0.0.2
