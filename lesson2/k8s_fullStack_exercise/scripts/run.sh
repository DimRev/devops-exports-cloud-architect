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

# kubectl wait --for=condition=available --timeout=60s deployment/mysql
# kubectl exec -it <mysql-pod-name> -n fullstack-app -- bash
# echo "MySQL is ready. Creating 'todos' table..."
#   mysql -h 127.0.0.1 -u root -p$MYSQL_ROOT_PASSWORD -D $MYSQL_DATABASE -e "
#     CREATE TABLE IF NOT EXISTS todos (
#       id INT AUTO_INCREMENT PRIMARY KEY,
#       title VARCHAR(255) NOT NULL,
#       description TEXT
#     );
#   "
kubectl apply -f ./manifests/mysql-service.yaml
kubectl apply -f ./manifests/mysql-externalname.yaml

# Deploy & Expose Backend
kubectl apply -f ./manifests/backend-deployment.yaml
kubectl apply -f ./manifests/backend-service.yaml

# Deploy & Expose Frontend
kubectl apply -f ./manifests/frontend-deployment.yaml
kubectl apply -f ./manifests/frontend-service.yaml

minikube tunnel