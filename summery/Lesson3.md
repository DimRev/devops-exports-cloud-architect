# Manage Kubernetes - Part 2

- [back](../README.md)

<u><b>Where did we stop?</b></u>
Last lesson we've talked about different k8s resources we spoke about configmaps secrets, namespaces and we've started talking about e2e app with a flask backend.

# Flask App

Continuing were we left off we'll first create a namespace for our app

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
```

Then we'll create a configmap for env variables for the app

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  namespace: my-namespace
data:
  DB_HOST: postgres
  DB_NAME: mydatabase
```

secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: my-namespace
type: Opaque
data:
  DB_USER: bXl1c2Vy
  DB_PASSWORD: bXlwYXNzd29yZA==
 
```

deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: my-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
        - name: flask-app
          image: <image tag>/flask-app:latest
          env:
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: my-config
                  key: DB_HOST
            - name: DB_NAME
              valueFrom:
                configMapKeyRef:
                  name: my-config
                  key: DB_NAME
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: my-secret
                  key: DB_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: my-secret
                  key: DB_PASSWORD
          ports:
            - containerPort: 5000
```

Notice that we are missing a `<image tag>/flask-app:latest`, the image needs to be hosted in a registry in order to be pulled from there, because we're AWS orientated we're going to host our image in AWS's registry called `ECR`

![Amazon Elastic Container](./assets/Pasted%20image%2020250203183033.png)

Here we create our registry, in order to communicate with the registry we need to authenticate with the registry using couple of methods

- Infrastructure as code, for example terraform
- Code, python for example can talk with aws using a lib
- AWS cli, we can use the aws cli to talk with the cli

Right now we're going to continue with `AWS CLI` that can be installed [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

In order to continue with AWS we need to create a user to provide it with relevant policies and creds so can log into the cli this is done via the `IAM` `AWS` service

I our user we can create a new access key,

Now we can run `aws configure` the aws configure command will take our access key and secret key and save them in our .aws dir to

now we can use this command to bind with docker

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your id>.dkr.ecr.us-east-1.amazonaws.com
```

Lets talk talk about this command

`aws` - aws binary
`ecr` - elastic container registry service
`get-login-password` -> used to pipe credentials to the docker login command
`docker  login` -> make the docker use the registry as it's login, this command will take the credentials from the ecr get-login-password command

create a k8s secret

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws user id>.dkr.ecr.us-east-1.amazonaws.com; kubectl create -n my-namespace secret docker-registry ecr-secret --docker-server=<aws user id>.dkr.ecr.us-east-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password --region us-east-1)
```

**Lets break down the cmd above**

```bash
aws ecr get-login-password --region us-east-1` - get the login password for the ecr
```

- Use the login password to login to the ecr

```bash
docker login --username AWS --password-stdin <aws user id>.dkr.ecr.us-east-1.amazonaws.com
```

- Create a secret for the ecr

```bash
kubectl create -n my-namespace secret docker-registry ecr-secret --docker-server=<aws user id>.dkr.ecr.us-east-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password --region us-east-1)
```

Setup a secret in the cluster, in the namespace we want to use to pull the image from the ecr

now we create a database deployment and it's services

postgres deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: my-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:latest
          env:
            - name: POSTGRES_DB
              valueFrom:
                configMapKeyRef:
                  name: my-config
                  key: DB_NAME
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: my-secret
                  key: DB_USER
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: my-secret
                  key: DB_PASSWORD
          ports:
            - containerPort: 5432
```

services:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: my-namespace
spec:
  selector:
    app: postgres
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
  namespace: my-namespace
spec:
  selector:
    app: flask-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: NodePort
```

As you can see we have 2 pods that are running in our cluster/namespace, a flask deployment and a postgres deployment

- Postgres exposes a clusterIP as a service
- Flask exposes a NodePort as a service

We can ssh into our flask pod and check the comm between them

```bash
kubectl exec -it -n my-namespace <flask-pod> -- sh
```

We can install a psql client and attempt to connect

```bash
apt-get update
apt-get install -y postgresql-client
```

now create a table after connecting to the database

```psql
CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL
);
```

Restart flask

```bash
kubectl rollout restart deployment/flask-app -n my-namespace
```

Now we can access the app in our kubectl's ip

```bash
minikube ip
```

## DNS - Example

For the dns example we'll create a simple nginx app with a busybox pod

namespace:

```yaml
apiVersion: v1
kind: Namespace
metadata: name: dns-example
```

nginx:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dns-example
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: dns-example
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

busybox-pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test-pod
  namespace: dns-example
spec:
  containers:
    - name: dns-test
      image: busybox
      command: ['sh', '-c',  "sleep 3600"]
```

ssh to pod:

```bash
kubectl exec -it dns-test-pod -n dns-example -- sh
```

Now we can lookup the service via it's name:

```
nslookup nginx-service
```

we can also lookup the env

```
printenv | grep -i service
```

responses

```bash
nslookup nginx-service
# Server:         10.96.0.10
#Address:        10.96.0.10:53
# ** server can't find nginx-service.cluster.local: NXDOMAIN
# ** server can't find nginx-service.svc.cluster.local: NXDOMAIN
# ** server can't find nginx-service.cluster.local: NXDOMAIN
# ** server can't find nginx-service.svc.cluster.local: NXDOMAIN
# Name:   nginx-service.dns-example.svc.cluster.local
# Address: 10.102.228.122

slookup nginx-service.dns-example.svc.cluster.local
# Server:         10.96.0.10
# Address:        10.96.0.10:53
# Name:   nginx-service.dns-example.svc.cluster.local
# Address: 10.102.228.122


printenv | grep -i service
# KUBERNETES_SERVICE_PORT=443
# NGINX_SERVICE_PORT_80_TCP=tcp://10.102.228.122:80
# NGINX_SERVICE_SERVICE_HOST=10.102.228.122
# NGINX_SERVICE_PORT=tcp://10.102.228.122:80
# NGINX_SERVICE_SERVICE_PORT=80
# KUBERNETES_SERVICE_PORT_HTTPS=443
# KUBERNETES_SERVICE_HOST=10.96.0.1
# NGINX_SERVICE_PORT_80_TCP_ADDR=10.102.228.122
# NGINX_SERVICE_PORT_80_TCP_PORT=80
# NGINX_SERVICE_PORT_80_TCP_PROTO=tcp
```

## Security

Inside docker desktop we can see the image variabilities

There are also various tools that can scan our app for variabilities on such program is `trivy` - installation [here](https://trivy.dev/latest/getting-started/installation/)
