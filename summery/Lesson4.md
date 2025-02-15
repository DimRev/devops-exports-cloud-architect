# Kubernetes components

[back](../README.md)

## Ingress

What is ingress and how can we describe it?
Lets assume we have a few deployment and each deployment has a few outside facing services, ingres is what points us towards the required services

```
DeploymentA
	|_ ServiceA(Internal:ClusterIP)
	|_ ServiceB -> Ingress
DeploymentB
	|_ ServiceA -> Ingress
	|_ ServiceB(Internal:ClusterIP)
```

### Exercise

Lets start our repo and get the project running first lets create a namespace:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
```

Next we'll create the ingress controller via the link

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

You can go to the link itself and check that it provides a complex yaml manifest for the ingress controller

Now we'll start creating our local components for our deployment

IngressClass:

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
```

Italian Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: italian-deployment
  labels:
    app: italian
spec:
  replicas: 2
  selector:
    matchLabels:
      app: italian
  template:
    metadata:
      labels:
        app: italian
    spec:
      containers:
        - name: italian-container
          image: nginx
          ports:
            - containerPort: 80
```

Italian Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: italian-service
spec:
  selector:
    app: italian
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30001
  type: NodePort
```

Chinese Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chinese-deployment
  labels:
    app: chinese
spec:
  replicas: 2
  selector:
    matchLabels:
      app: chinese
  template:
    metadata:
      labels:
        app: chinese
    spec:
      containers:
        - name: chinese-container
          image: nginx
          ports:
            - containerPort: 80
```

Chinese-service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: chinese-service
spec:
  selector:
    app: chinese
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30002
  type: NodePort
```

Now we'll define our ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: restaurant-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: italian.food.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: italian-service
            port:
              number: 80
  - host: chinese.food.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: chinese-service
            port:
              number: 80
```

Some clerifications

if we run

```yaml
kubectl get all
```

We'll get:
![](./assets/Pasted%20image%2020250211111737.png)

We can see that we have 2 pods for each deployment, services for each deployment

Lets see our ingress:
![](./assets/Pasted%20image%2020250211111935.png)

Now we can run the to check our ingress we'd need to `minikube tunnel` and add the `italian.food.local` and `chinese.food.local` to our known hosts (in windows) `C:\Windows\System32\drivers\etc\hosts`

![[Pasted image 20250214121549.png]]
Notice, that the the k8s is mapped to the localhost(127.0.0.1) as the minikube tunnel runs the k8s as localhost.

### Summary

To summarize all the exercise above the flow goes as following
We've created a nginx ingress class that defines the ingress controller, then we create the service in our app the service exposes port 80 which the ingress service "catches" and exposes to the outside world

`chinese.food.local -> chinese-service -> chinese-deployment`

## Volumes

The next component we will talk about are volume, when we are talking about a simple web app we're talking about a few components, a frontend, a backend, a database and a storage

When we run pods/deployments our frontend could fall and it won't cause another issue same goes for the backend itself, but the place that store data and storage should be persistent

Another problem arises when we want to have 2 applications write and read the same data(volume)

The components that we are using for the volume interactions are PV and PVC, PersistentVolume and PersistentVolumeClaims

### Exercise

We'll start by creating our PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:  path: /mnt/data
```

This pv defines a volume that is located in our cluster itself at `/mnt/data` and is `1Gi` of size with access to this file of `ReadWriteOnce` which basically means only pvc can read and write in this volume

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

This pvc's role is to basically get bound into a pv and expose it to a deployment

And also we'll be dockerizing our python app

```python
from flask import Flask, request, jsonify
import os

app = Flask(__name__)
data_file = "/data/data.txt"

@app.route('/')
def home():
    return "Welcome to the Flask App with Persistent Storage!"

@app.route('/write', methods=['POST'])
def write_data():
    content = request.json.get('content')
    with open(data_file, 'a') as f:
        f.write(content + '\n')
    return jsonify({"message": "Data written to file"}), 200

@app.route('/read', methods=['GET'])
def read_data():
    if os.path.exists(data_file):
        with open(data_file, 'r') as f:
            content = f.readlines()
        return jsonify({"data": content}), 200
    else:
        return jsonify({"message": "No data found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Our simple app basically reads and writes to a file using POST and GET methods

To containerize this app we'll use the following Dockerfile

```Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

**Uploading to registry:**
Docker hub is Registry is a free registry that allows you to store a single private repo and an undefiant amount of public containers

Loggin in the docker desktop with your dockerhub user

to tag and build

```bash
docker build .\
  -t <username>/<container_name>:latest\
  -t <username>/<container_name>:v<version>
```

and push

```bash
docker push <username>/<container_name>:latest
docker push <username>/<container_name>:v<version>
```

With the following commands our container was pushed to the docker hub

flask deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      containers:
        - name: flask
          image: <username>/<container_name>:latest
          volumeMounts:
            - mountPath: '/data'
              name: my-storage
          ports:
            - containerPort: 5000
      volumes:
        - name: my-storage
          persistentVolumeClaim: claimName: my-pvc
```

As you can see this deployment has a couple of new items, the image being pulled from our docker hub which is one difference.
Another difference is that the spec contains the volume section which points to the pvc we've defined earlier

We'll give our flask service a nodeport:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  selector:
    app: flask
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: NodePort
```

Now we can expose the app via `minikube service flask-service --url` this will give us our mapped localhost port:

![](./assets/Pasted%20image%2020250215100143.png)

![](./assets/Pasted%20image%2020250215100201.png)

Now let's check reading and writing to the app:

Using REST API mocking software we can do the following:
writing:
![](./assets/Pasted%20image%2020250215100452.png)
Reading:
![](./assets/Pasted%20image%2020250215100522.png)

Now in order to confirm that our data is persistent and won't disappear when the pod dies let's kill the pod ourselves
![](./assets/Pasted%20image%2020250215100924.png)

Because our pod is part of a deployment deleting the pod will automatically start a new one

![](./assets/Pasted%20image%2020250215101059.png)

And with this lets try to read and write to the file again:

Write:
![](./assets/Pasted%20image%2020250215101134.png)
Read:
![](./assets/Pasted%20image%2020250215101150.png)

As you can see the writing succeeded and the reading shows us the `Hello k8s\n` which was left from the previous pod meaning that this data is persistent.

Now lets create a second pvc

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc2
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

We can see that the second pvc got bounded aswell as the first one, what's happening here?
![](./assets/Pasted%20image%2020250215101844.png)

What happens here is basically the pvc is basically creating a pv if it isn't able to bound to any existing pv

## Stateful Set

To understand what is a stateful set lets first talk about a replica set:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
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
          image: nginx:latest
          ports:
            - containerPort: 80
```

This is a simple replica set that will boot 3 replicas of an nginx images that will expose port 80, simple enough.
![[Pasted image 20250215102930.png]]

To understand what is a statful set, lets think about a case where a single pod gets dropped in that case the deployment will handle the booting up of another pod, but what happens if we have configured that pod manually to have some apps i.e. curl/ping or whatever while we were working with it, obviously those apps will get removed as the new pod won't save their state.

Now stateful set allows us to not only control the number of replicas of a given pod but their internal state aswell, we are basically mapping them to an outside volume and making changes on it while running the pod making the state of the pod persistent

### Exercise

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-statefulset
spec:
  serviceName: "nginx"
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
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: nginx-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

As shown above the nginx statefull set looks similar to a stateful set but it has a volume attached to it:

![](./assets/Pasted%20image%2020250215103832.png)
![](./assets/Pasted%20image%2020250215103843.png)
![](./assets/Pasted%20image%2020250215103918.png)

We've applyed the stateful set lets talk about what happened:
The stateful set gets 0 indexed, and each set gets a pvc attached to it, when we deleted one of the stateful pods from the deployment that same pod will get rised again

## Daemon Set

Another type of set that exists for deployments is a deamon set:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  labels:
    app: nginx
spec:
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

Daemon set creates a pod that runs for each deployment, for example lets talk about a cluster each node is an instance of ec2, and i'm running a daemon set of nginx, that means each ec2 instance gets an nginx pod running inside it via the daemon set

## Cron Jobs

Cron job is a scheduled job that will start in \* \* \* \* \* time.
Inside k8s we already have a sechedual that allows us to time cron jobs

### Exercise

Lets create a simple python logging script

```python
import datetime
import logging

# Configure logging
logging.basicConfig(filename='/app/logs/cronjob.log', level=logging.INFO)

def log_message():
    current_time = datetime.datetime.now()
    message = f"CronJob executed at {current_time}"
    logging.info(message)
    return message

if __name__ == "__main__":
    log_message()
```

Lets build this into a container and push it to dockerhub:

```Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY . /app

RUN mkdir -p /app/logs

CMD ["python", "script.py"]
```

Now we can create a cronjob manifest:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: python-cronjob
spec:
  schedule: "*/1 * * * *"  # Runs every 5 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: python-cronjob-container
            image: summaryexperts/cronjob-python:latest  # Replace with your Docker image name
            volumeMounts:
            - name: logs
              mountPath: /app/logs
          restartPolicy: OnFailure
          volumes:
          - name: logs
            emptyDir: {}
```

We apply this and we can check it:

![](./assets/Pasted%20image%2020250215110518.png)

We can see the pods for the script:
![](./assets/Pasted%20image%2020250215110545.png)
