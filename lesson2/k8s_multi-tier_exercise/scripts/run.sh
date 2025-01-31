#!/bin/bash

# Setup namespace and resources
kubectl apply -f manifests/mta/multi-tier-app-namespace.yaml
kubectl apply -f manifests/mta/multi-tier-app-resourcequota.yaml

# Deploy Redis
kubectl apply -f manifests/redis/redis-configmap.yaml
kubectl apply -f manifests/redis/redis-deployment.yaml
kubectl apply -f manifests/redis/redis-service.yaml
kubectl apply -f manifests/redis/redis-externalname.yaml

# Deploy Backend
kubectl apply -f manifests/backend/backend-configmap.yaml
kubectl apply -f manifests/backend/backend-deployment.yaml
kubectl apply -f manifests/backend/backend-service.yaml

# Deploy Frontend
kubectl apply -f manifests/frontend/frontend-deployment.yaml
kubectl apply -f manifests/frontend/frontend-service.yaml

kubectl get services -n multi-tier-app
minikube tunnel