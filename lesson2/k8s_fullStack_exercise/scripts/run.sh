#!/bin/bash

kubectl delete namespace fullstack-app --ignore-not-found=true

# Apply namespace-level resources
  # GLOBAL
kubectl apply -f ./manifests/fullstack-namespace.yaml
kubectl apply -f ./manifests/fullstack-resourcequota.yaml


# Apply ConfigMaps & Secrets
  # MYSQL
kubectl apply -f ./manifests/mysql-configmap.yaml
kubectl apply -f ./manifests/mysql-secret.yaml
  # BACKEND
kubectl apply -f ./manifests/backend-configmap.yaml
kubectl apply -f ./manifests/backend-secret.yaml

# Deploy & Expose MYSQL
kubectl apply -f ./manifests/mysql-deployment.yaml
./scripts/init-db.sh

kubectl apply -f ./manifests/mysql-service.yaml
kubectl apply -f ./manifests/mysql-externalname.yaml

# Deploy & Expose Backend
kubectl apply -f ./manifests/backend-deployment.yaml
kubectl apply -f ./manifests/backend-service.yaml

# Deploy & Expose Frontend
kubectl apply -f ./manifests/frontend-deployment.yaml
kubectl apply -f ./manifests/frontend-service.yaml

kubectl get services -n fullstack-app

minikube tunnel