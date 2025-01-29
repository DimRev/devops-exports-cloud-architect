#!/bin/bash

# Function to clean up background processes on exit
cleanup() {
    echo "Stopping Minikube tunnel..."
    kill $TUNNEL_PID
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM to clean up properly
trap cleanup SIGINT SIGTERM

# Start Minikube tunnel in the background and store its PID
echo "Starting Minikube tunnel..."
(minikube tunnel > /dev/null 2>&1 &) &
TUNNEL_PID=$!
echo "Minikube tunnel PID: $TUNNEL_PID"

# Delete the namespace if it exists
kubectl delete namespace fullstack-app --ignore-not-found=true

# Apply namespace-level resources
kubectl apply -f ./manifests/fullstack-namespace.yaml
kubectl apply -f ./manifests/fullstack-resourcequota.yaml

# Apply ConfigMaps & Secrets
kubectl apply -f ./manifests/mysql-configmap.yaml
kubectl apply -f ./manifests/backend-configmap.yaml
kubectl apply -f ./manifests/mysql-secret.yaml

# Deploy & Expose Database
kubectl apply -f ./manifests/mysql-deployment.yaml
kubectl apply -f ./manifests/mysql-service.yaml
kubectl apply -f ./manifests/mysql-externalname.yaml

# Deploy & Expose Backend
kubectl apply -f ./manifests/backend-deployment.yaml
kubectl apply -f ./manifests/backend-service.yaml

# Deploy & Expose Frontend
kubectl apply -f ./manifests/frontend-deployment.yaml
kubectl apply -f ./manifests/frontend-service.yaml

echo "Deployment complete! Minikube tunnel is running in the background."

# Keep the script running to maintain the tunnel (if needed)
wait $TUNNEL_PID
