#!/bin/bash

cleanup() {
  echo "[INFO]: Cleaning up..."
  kubectl delete namespace fullstack-app --ignore-not-found=true
  exit 0
}

echo "[Assignment 1]: Creating Namespace"
echo "Press any key to continue..."
read -n 1 -s
kubectl apply -f ./manifests/fullstack-namespace.yaml

