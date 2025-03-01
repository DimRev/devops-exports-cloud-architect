# Kubernetes Components

- [back](../README.md)

This is our continuation of Kubernetes components, together with connecting them into our cloud, today we're going to make those connections.

We've stopped with vertical and horizontal pod auto-scaling, what does that mean:

- Vertical scaling (VPA), meaning that if we have a single compute unit we're making the compute unit larger from 17gb ram to 32gb ram for example
- Horizontal scaling (HPA), meaning we're increasing from a single 16gb unit to 2 units with 16gb each quantitively scaling

## HPA

### Exercise

Let's create a simple flask app.

```python
from flask import Flask
import time

app = Flask(_name_)

@app.route("/")
def hello():
    return "Hello, Kubernetes!"

@app.route("/cpu")
def cpu_load():
    # Simulates CPU load by running a loop for a few seconds
    start_time = time.time()
    while time.time() - start_time < 2:
        pass
    return "CPU load simulated"

if _name_ == "_main_":
    app.run(host="0.0.0.0", port=5000)
```

What does it do, We're simulating load on our CPU via a loop, each x time we're simulating load.

In this exercise what is going to happen is that we're going to scale our deployment when the app is in load.

```Dockerfile
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

In this exercise we're going to use the basic dockerhub.

```bash
docker build .\
	-t <username>/<container_name>:<version>
```

```bash
docker push <username>/<container_name>:<version>
```

Now this is our deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
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
        image: summaryexperts/flask-app-hpa:latest
        ports:
        - containerPort: 5000
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```

A little note about our deployment there's a section in it talking about the requests and the limits, which is basically talking about how much resources the deployment is requesting by default and where is the upper limit of the resources.

Lets create our service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  type: NodePort
  selector:
    app: flask-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
      nodePort: 30007
```

Now we're going to handle our autoscaling:

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: flask-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: flask-app
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

Now lets talk about our hpa:

![Horizontal Pod Autoscaler](./assets/Pasted%20image%2020250217184610.png)
As we can see we don't know what our CPU is at the moment, but in 50% we're going to trigger scale target and rise the pods

Out local minikube isn't exact so the `<unknown>` is something that should only happen locally

locally reaching our scaling target would be difficult to reach, but we can do that easier when we move this to the cloud

## HELM

Lets talk about helm, what is it, and how we work with it.

Helm solves a problem where our yaml files are hard coded with variables being duplicated all over the files and intertwined between them, also in case we want to have different env i.e. production, staging, dev, we will find ourselves with a copy of multiple files

after installing helm via the guide in [here](https://helm.sh/docs/intro/install/) we'll create our helm chart using

```bash
helm create my-application
```

This will create a dir with the following manifests:

![Helm Chart](./assets/Pasted%20image%2020250217190400.png)

The yaml files should be familier to us, but the chart.yaml and the values.yaml

- Chart describes our current app
- values are global variables that can be used in the templates

Now lets try to understand what we are seeing in the default helm chart:

Chart.yaml:

```yaml
apiVersion: v2
name: my-application
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: '1.16.0'
```

- Chart holds the metadata about our application, the description the application name the current version

values.yaml:

```yaml
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.16"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

nodeSelector: {}
tolerations: []
affinity: {}

configmap:
  myKey: "myValue"

secret:
  username: admin
  password: changeme

serviceAccount:
  create: true
  name: ""

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

- The values is besically a key-value dictionery that stores variables that can be reused in our templates for example `{{ secret.username }}` will map to the value `admin`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: { { include "my-application.fullname" . } }
  labels:
    app: { { include "my-application.name" . } }
spec:
  replicas: { { .Values.replicaCount } }
  selector:
    matchLabels:
      app: { { include "my-application.name" . } }
  template:
    metadata:
      labels:
        app: { { include "my-application.name" . } }
    spec:
      containers:
        - name: { { .Chart.Name } }
          image: '{{ .Values.image.repository }}:{{ .Values.image.tag }}'
          ports:
            - containerPort: 80
          resources:
            limits:
              cpu: { { .Values.resources.limits.cpu } }
              memory: { { .Values.resources.limits.memory } }
            requests:
              cpu: { { .Values.resources.requests.cpu } }
              memory: { { .Values.resources.requests.memory } }
          envFrom:
            - configMapRef:
                name: { { include "my-application.fullname" . } }
            - secretRef:
                name: { { include "my-application.fullname" . } }
      nodeSelector: { { .Values.nodeSelector | toYaml | nindent 8 } }
      tolerations: { { toYaml .Values.tolerations | nindent 8 } }
      affinity: { { toYaml .Values.affinity | nindent 8 } }
```

As we can see `.Values.<value>` will take the value of some kv mapped value

service.yaml:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: { { include "my-application.fullname" . } }
  labels:
    app: { { include "my-application.name" . } }
spec:
  type: { { .Values.service.type } }
  ports:
    - port: { { .Values.service.port } }
      targetPort: 80
  selector:
    app: { { include "my-application.name" . } }
```

The service does the same and maps the values to our service file

ingress.yaml:

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "my-application.fullname" . }}
  annotations:
    {{- range $key, $value := .Values.ingress.annotations }}
      {{ $key }}: {{ $value | quote }}
    {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "my-application.fullname" . }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
{{- end }}
```

Notice a few interesting things about our ingress, there is a loop here via `range` our range, ranges over our paths and create a ingress path for each of them

configmap.yaml:

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: { { include "my-application.fullname" . } }
data:
  myKey: { { .Values.configmap.myKey | quote } }
```

secrets.yaml:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: { { include "my-application.fullname" . } }
type: Opaque
data:
  username: { { .Values.secret.username | b64enc | quote } }
  password: { { .Values.secret.password | b64enc | quote } }
```

The last file we haven't spoken about is the

`_helpers.tpl`

```tpl
{{- define "my-application.name" -}}
{{- if .Chart -}}
{{- if .Chart.Name -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
"my-application"
{{- end -}}
{{- else -}}
"my-application"
{{- end -}}
{{- end }}

{{- define "my-application.fullname" -}}
{{- if .Chart -}}
{{- include "my-application.name" . }}-{{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else -}}
"my-application-fullname"
{{- end -}}
{{- end }}

{{- define "my-application.chart" -}}
{{- if and .Chart .Chart.Name .Chart.Version -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" -}}
{{- else -}}
"my-application-chart"
{{- end -}}
{{- end }}

{{- define "my-application.labels" -}}
{{- $labels := dict "app.kubernetes.io/name" (include "my-application.name" .) "helm.sh/chart" (include "my-application.chart" .) -}}
{{- if .Chart.AppVersion }}
{{- $_ := set $labels "app.kubernetes.io/version" .Chart.AppVersion -}}
{{- end -}}
{{- if .Chart.Version }}
{{- $_ := set $labels "helm.sh/chart" .Chart.Version -}}
{{- end -}}
{{- $labels | toYaml | nindent 4 -}}
{{- end }}
```

The `_helper.tpl` is the helpers functions that we can reuse inside our templates like the application name or application fullname

serviceaccount.yaml:

```yaml
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name | default (include "my-application.fullname" .) }}
  labels:
    {{- include "my-application.labels" . | nindent 4 }}
{{- end }}
```

hpa.yaml:

```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "my-application.fullname" . }}
  labels:
    {{- include "my-application.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "my-application.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  targetCPUUtilizationPercentage: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
```

lets deploy

```
helm install my-new-release .\my-application
```

we can check our release with

```
helm list
```

![Helm List](./assets/Pasted%20image%2020250217195803.png)

```
helm status my-new-release
```

![Helm Status](./assets/Pasted%20image%2020250217195844.png)
![Kubectl Get Deployment](./assets/Pasted%20image%2020250217200012.png)

So what happened, we used helm to deploy to kubernetes, now handled and managed by HELM.

Helm is also helps us version controll our apps, we can use

```
kubectl rollout status deployment/<app name>
```

to rollback our versions to a previous version

## Cloud

There's an anlalogy for all our k8s components to cloud components in AWS

### Exercise

#### EC2

Lets start a new free ec2 instance:

![EC2 Instance](./assets/Pasted%20image%2020250217202814.png)

With our ec2 instance in the air we can buy domains from aws or any other domain vendor

We can set an elastic ip to our machine to lock it's ip:

We can connect the ip with a machine
![Elastic IP](./assets/Pasted%20image%2020250217203914.png)

#### LoadBalancer - http

Now we'll create two nginx instances with different pages to see that load balancer
