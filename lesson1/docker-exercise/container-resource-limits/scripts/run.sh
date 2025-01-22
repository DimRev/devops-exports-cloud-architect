#!/bin/bash

echo "Building container-resource-limits image..."

docker run -d --name crl-exercise --memory=256m --cpus=1 python:3.9-slim python -c "while True: pass"
