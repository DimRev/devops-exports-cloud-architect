# Kubernetes (K8S) YAML Exercise: Full-Stack Application Deployment on Minikube

This exercise will guide you through deploying a simple full-stack application using Kubernetes (K8S) on Minikube. The application will include a database, a backend server, and a frontend server. You will learn to work with deployments, pods, replicas, namespaces, resource quotas, services, ConfigMaps, and Secrets.

## Prerequisites

- Minikube installed and running on your local machine
- Basic knowledge of Kubernetes and YAML syntax

## Exercise Overview

1. <u>Create a Namespace</u>
2. <u>Set a Resource Quota</u>
3. <u>Deploy a MySQL Database</u>
4. <u>Deploy a Backend Server</u>
5. <u>Deploy a Frontend Server</u>
6. <u>Configure Services (ClusterIP, NodePort, ExternalName)</u>
7. <u>Use ConfigMaps for Configuration</u>
8. <u>Use Secrets for Sensitive Data</u>

## Instructions

1. <u><b>Create a Namespace</b></u>

- Create a namespace called `fullstack-app` to isolate the resources.

2. <u><b>Set a Resource Quota</b></u>

- Set a resource quota for the namespace to limit resource usage.

3. <u><b>Deploy a MySQL Database</b></u>

- Create a Secret for the MySQL root password and a ConfigMap for database configuration.
- Create a Secret for the MySQL root password.
- Create a ConfigMap for MySQL database configuration.
- Deploy MySQL with the created Secret and ConfigMap.

4. <u><b>Deploy a Backend Server</b></u>

- Deploy the backend server with environment variables configured to connect to the MySQL database.
- Ensure the backend server has three replicas.

5. <u><b>Deploy a Frontend Server</b></u>

- Deploy the frontend server with environment variables configured to connect to the backend server.
- Ensure the frontend server has three replicas.

6. <u><b>Configure Services</b></u>

- Create a ClusterIP service for the MySQL database.
- Create a ClusterIP service for the backend server.
- Create a NodePort service for the frontend server.
- Create an ExternalName service to map an external DNS name.

7. <u><b>Use ConfigMaps for Configuration</b></u>

- Create a ConfigMap for the backend server configuration.

8. <u><b>Use Secrets for Sensitive Data</b></u>

- Create a Secret for storing API keys used by the backend server.

## Testing the Setup

Once everything is deployed, you can test the setup using `curl` commands.

1. Check the Frontend Service:

```sh
curl http://<minikube-ip>:30001
```

2. Access the Backend Service from the Frontend Pod:

```sh
kubectl exec -it <frontend-pod> -n fullstack-app -- curl http://backend:8080
```

3. Verify Database Connection from the Backend Pod:

```sh
kubectl exec -it <backend-pod> -n fullstack-app -- curl http://mysql:3306
```

## Submission

Please submit the following YAML files:

1. Namespace definition

- [fullstack-namespace.yaml](./k8s_fullStack_exercise/manifests/fullstack-namespace.yaml)

2. Resource Quota definition

- [fullstack-resourcequota.yaml](./k8s_fullStack_exercise/manifests/fullstack-resourcequota.yaml)

3. Secret for MySQL root password

- [mysql-secret.yaml](./k8s_fullStack_exercise/manifests/mysql-secret.yaml)

4. ConfigMap for MySQL configuration

- [mysql-configmap.yaml](./k8s_fullStack_exercise/manifests/mysql-configmap.yaml)

5. MySQL Deployment and Service

- [mysql-deployment.yaml](./k8s_fullStack_exercise/manifests/mysql-deployment.yaml)
- [mysql-service.yaml](./k8s_fullStack_exercise/manifests/mysql-service.yaml)

6. Backend Deployment and Service

- [backend-deployment.yaml](./k8s_fullStack_exercise/manifests/backend-deployment.yaml)
- [backend-service.yaml](./k8s_fullStack_exercise/manifests/backend-service.yaml)

7. Frontend Deployment and Service

- [frontend-deployment.yaml](./k8s_fullStack_exercise/manifests/frontend-deployment.yaml)
- [frontend-service.yaml](./k8s_fullStack_exercise/manifests/frontend-service.yaml)

8. ConfigMap for Backend configuration

- [backend-configmap.yaml](./k8s_fullStack_exercise/manifests/backend-configmap.yaml)

9. Secret for API keys

10. ExternalName Service definition

- [mysql-externalname.yaml](./k8s_fullStack_exercise/manifests/mysql-externalname.yaml)
