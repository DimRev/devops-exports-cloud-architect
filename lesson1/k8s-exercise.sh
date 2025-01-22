#!/bin/bash
# Prerequisites - Start Kubernetes cluster via Minikube

set -e

# Cleanup function to handle interruption or errors
cleanup() {
    echo -e "\n[INFO] Cleaning up resources..."
    kubectl delete pod nginx --ignore-not-found=true
    kubectl delete deployment nginx-deployment --ignore-not-found=true
    kubectl get all -A
}

# Trap INT (Ctrl+C) and ERR to call the cleanup function
trap cleanup INT ERR

# Confirm that Minikube has started
echo "[PREREQUISITE] Press any key to confirm that Minikube has started..."
read -r -n 1  
minikube status
echo "[PREREQUISITE] Press any key to checking kubectl resources..."
read -r -n 1
kubectl get all -A

# Assignment 1 - Create a simple Pod
echo "[ASSIGNMENT 1] Press any key to create a simple Pod..."
read -r -n 1 
kubectl run nginx --image=nginx

# Assignment 2 - View Pod details
echo "[ASSIGNMENT 2] Press any key to view Pod details..."
read -r -n 1 
kubectl get pods

# Assignment 3 - Delete a Pod
echo "[ASSIGNMENT 3] Press any key to delete a Pod..."
read -r -n 1 
kubectl delete pod nginx
kubectl get pods

# Assignment 4 - Create a Deployment
echo "[ASSIGNMENT 4] Press any key to create a Deployment..."
read -r -n 1 
kubectl create deployment nginx-deployment --image=nginx
kubectl get deployments

echo "[ASSIGNMENT 4] Press any key to scale the Deployment to 3 replicas..."
read -r -n 1
kubectl scale deployment nginx-deployment --replicas=3
kubectl get deployments

# Assignment 5 - Access a Deployment via Port Forwarding
echo "[ASSIGNMENT 5] Press any key to access a Deployment via Port Forwarding..."
read -r -n 1 
kubectl port-forward deployment/nginx-deployment 8080:80

# End of script
echo "[INFO] Script execution completed. Exiting."

