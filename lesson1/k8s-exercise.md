# Basic Kubernetes exercise

- [Back](../README.md)
- [ec2 Exercise](ec2-exercise.md)

## Creating a Simple Pod

- [Solution](k8s-exercise.sh)

- **Explanation**: A Pod is the smallest deployable unit in Kubernetes. It encapsulates one or more containers.
- **Task**: Use the `kubectl` command to create a Pod running an Nginx container.

## Viewing Pod Details

- **Explanation**: Kubernetes provides commands to inspect the details of running Pods.
- **Task**: View detailed information about the Nginx Pod you created earlier.

## Deleting a Pod

- **Explanation**: Pods can be deleted using `kubectl` commands.
- **Task**: Delete the Nginx Pod you created earlier.

## Creating a Deployment

- **Explanation**: A Deployment manages a set of identical Pods and ensures the desired number of replicas are running.
- **Task**: Create a Deployment for an Nginx application with 3 replicas.

## Accessing a Deployment via Port Forwarding

- **Explanation**: Port forwarding allows you to access applications running in Pods directly from your local machine.
- **Task**: Forward a local port to a port on one of the Pods in the Deployment to access the Nginx application.
