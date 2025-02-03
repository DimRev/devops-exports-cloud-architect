# Cloud Architect

- [back](../README.md)

This course will cover advanced and more complicated topics related to the world of DevOps.

During the course sessions we will deal with few main subjects related to the DevOps world:

1.  Cloud architecture and management
2.  Container orchestration
3.  Infrastructure as code
4.  Security in the world of DevOps
5.  Course project

## AWS Services

### EC2

EC2 is one of the oldest services that is available in aws, ec2 is a an elastic compute unit where we can configure which hardware and software specs the compute is running.

#### Exercise

We're going to rise an ec2 instance that is running an ubuntu as it's OS, AWS gives us 750 free tier hours per instance

instance - We select an ubuntu as the OS of the system, we are selecting the instance type to be `t2.micro` as both of those are free tier eligible, it is denoted in the right side of the selection

network - We use/create a key-pair while we setup the network connection to ssh

volume - defining a volume an ebs's free tier is 30GiB, notice that amazon defines sizes with GiB instead of GB, GB = 1024 mb, while GiB is a 10(dec) based system.

#### Connecting to the machine

There are a few ways to connect to the machine though, one of them is ssh though the aws web app

Another way is to connect to the machine via ssh

```bash
ssh -i <path-to-pem> <user>@<machine-public-ip>
```

### Installing docker on the e2 instance

To install docker on our ec2 instance we use

- Pre-requesites

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

- Docker installation

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- Docker test

```bash
sudo docker run hello-world
```

If everything went right the docker run should return a hello world output, if not? Good luck debugging.

## Docker Introduction

- Docker is a software container platform.
  - <u>`Developers`</u> - use docker to eliminate "works on my machine" problems when collaborating on code with co-workers
  - <u>`Operators`</u> - use Docker to run and manage apps side-by-side in isolated containers to get better compute density
  - <u>`Enterprise` </u>- use Docker to build agile software delivery piplelines to ship new features faster, more secure and with confidence for both Linux and Windows Server apps

### Virtual Machines vs Docker Containers

- Docker containers are not virtual machines
- IN Virtual machines, there is a huge waste of memory.
- The difference between the structure of VM and Docker

### Docker image

```bash
sudo docker pull nginx:latest
```

We will run our docker image instance via the bash script

```bash
sudo docker run --name my-nginx -p 8080:80 -d nginx
```

- `sudo` - super user do - run as root
- `docker run` - run container
- `--name my-nginx` - give the container a static name
- `-p 8080:80` - bound the outside port (local) 8080, to the container's port 80
- `-d` - run in detach mode
- `nginx` - name of the container we run

After we run this container we can go to our ec2 machine and setup it's security group to allow inbound access to port `8080`.

## What is Container Orchestration

Container orchestration is all about managing the life socles of containers, especially in large, dynamic environments. Software teams use containers orchestration to control and automate many tasks:

### Kubernetes Architecture

![k8s Architecture](./assets/Pasted%20image%2020250120200319.png)

- Master node is responsible for managing the cluster. Monitoring nodes and pods in a cluster. When a node fails, moves the workload of the failed <..Continue here...>

## Running local K8s

### Minikube

Minikube is a k8s distro thats useful for locally running docker for tests and for learning minikube shouldn't be used for production

### Kubernetes Deployments

k8s deployment is a way to statically manage the wanted state in the end of the deployment this

```bash
Replicas:
1 desired | 1 updated | 1 total | 1 available | 0 unavailable
```

The deployment itself will handle rising and killing wanted/unwanted pods

```bash
kubectl scale deployment/hello-node --replicas=3
```

- The following command will increase our desired replicas that are running in our cluster

#### Minikube debug

In case minikube has problems starting with docker, this command can explicitly start minikube with docker

```bash
minikube start --driver=docker
```
