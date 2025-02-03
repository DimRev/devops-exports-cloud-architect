# Manage Kubernetes

When we want to manage kubernetes configs to make them repeatable we would want to use yaml files for our settings.

## Namespace

### What is a namespace?

A namespace allows us to create isolation between components

**_Example:_**

1. We'll create two namespaces `team-a`, `team-b`

```bash
kubectl create namespace team-a
kubectl create namespace team-a

kubectl get namespace # This will show us that we created the correct namespaces
```

2. We'll create a yaml for our nginx-team-a deployment

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx
  namespace: team-a

spec:
  replicas: 3
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
          image: nginx
          ports:
            - containerPort: 80
```

3.  Apply the deployment

```bash
kubectl apply -f <path_to_yaml>
kubectl get deployment -n team-a
```

As we have mantioned before a namespace splits our perimissions and isolates the given deployments.

4. Add resource quota:

```yaml
apiVersion: v1
kind: ResourceQuota

metadata:
  name: quota
  namespace: team-a

spec:
  hard:
    pods: '10'
    requests.cpu: '2'
    requests.memory: '16Gi'
    limits.cpu: '8'
    limits.memory: '32Gi'
```

Now we add the resource quota "rules" to our namespace

```bash
kubectl get resourcequota quota -n team-a
```

## Services

What are services, service provides us the ability to expose our cluster/pod to the outside

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: backend-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx
        ports:
        - containerPort: 80
```

```yaml
apiVersion: v1
kind: Service

metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

- The default service that gets created via the kind: Service is clusterIP service which give the pod/namespace a internal facing spacing ip

Another type of service is a NodePort:

```yaml
apiVersion: v1
kind: Service

metadata:
  name: frontend-service
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30007
```

- The node Port exposes the pod/deploylment to the outside

The next service is a LoadBalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

A loadBalancer basically tunnels the requests though it towards different pods that are connected to it, it uses internal logic to choose which pod to send the request to

The next service will be externalName

```yaml
apiVersion: v1
kind: Service

metadata:
  name: external-postgres

spec:
  type: ExternalName
  externalName: postgres-service.default.svc.cluster.local
```

This is basically an internal DNS that maps the dns to a name

# Config map

Config map allows us to store the configuration, env values in a separated file

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: my-config
data:
  APP_ENV: production
  APP_DEBUG: 'true'
```

# Secret

Secret kind can translate encoded envs to decoded values

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: bXl1c2Vy
  password: bXlwYXNzd29yZA==
```
