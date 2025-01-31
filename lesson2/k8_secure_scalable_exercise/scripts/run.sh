#!/bin/bash

# Namespace creation
kubectl apply -f ./manifests/ns/secure-app-namespace.yaml
kubectl apply -f ./manifests/ns/secure-app-resourcequota.yaml
kubectl apply -f ./manifests/ns/secure-app-role.yaml
kubectl apply -f ./manifests/ns/secure-app-rolebinding.yaml

# Configs and Secrets
kubectl apply -f ./manifests/mongo/mongo-configmap.yaml
kubectl apply -f ./manifests/mongo/mongo-secret.yaml
kubectl apply -f ./manifests/backend/backend-configmap.yaml

# Mongo
kubectl apply -f ./manifests/mongo/mongo-deployment.yaml
kubectl apply -f ./manifests/mongo/mongo-service.yaml
kubectl apply -f ./manifests/mongo/mongo-externalname.yaml

# Backend
kubectl apply -f ./manifests/backend/backend-deployment.yaml
kubectl apply -f ./manifests/backend/backend-service.yaml

# Frontend
kubectl apply -f ./manifests/frontend/frontend-deployment.yaml
kubectl apply -f ./manifests/frontend/frontend-service.yaml

kubectl get services -n secure-app

minikube tunnel