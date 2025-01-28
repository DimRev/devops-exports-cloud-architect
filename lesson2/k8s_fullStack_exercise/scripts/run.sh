#!/bin/bash

kubectl apply -f ./manifests/fullstack-namespace.yaml
kubectl apply -f ./manifests/fullstack-resourcequota.yaml

kubectl apply -f ./manifests/mysql-configmap.yaml
kubectl apply -f ./manifests/mysql-secret.yaml
kubectl apply -f ./manifests/mysql-deployment.yaml
kubectl apply -f ./manifests/mysql-service.yaml
kubectl apply -f ./manifests/mysql-externalname.yaml

kubectl apply -f ./manifests/backend-configmap.yaml
kubectl apply -f ./manifests/backend-deployment.yaml


