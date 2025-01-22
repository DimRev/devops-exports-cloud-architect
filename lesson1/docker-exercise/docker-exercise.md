# Advanced Docker Exercises

[Back](../README.md)

## Multi-Stage Builds

- **Explanation**: Multi-stage builds allow you to create lean Docker images by separating the build and runtime environments into multiple stages.
- **Task**: Create a Dockerfile for a Node.js app. Use the first stage to install dependencies and build the app, and the second stage to copy the build artifacts into a minimal runtime image.
- **Example**:

```Dockerfile
# Stage 1: Build
FROM node:16 AS builder
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist /app
CMD ["node", "app.js"]
```

- [Solution](multi-stage-build/Dockerfile)

## Docker Networking

- **Explanation**: Docker allows you to create custom networks for containers to communicate securely and efficiently.
- **Task**: Create three containers (e.g., a web server, a backend API, and a database) in a custom Docker bridge network and test their connectivity using `ping` or API calls.
- **Example**:

```bash
docker network create my_network
docker run -d --name web --network my_network nginx
docker run -d --name backend --network my_network alpine ping backend
```

- [Solution](docker-network/docker-compose.yaml)

## Docker Volumes

- **Explanation**: Volumes provide persistent storage for containers, allowing data to survive when the container stops or restarts.
- **Task**: Create a Docker Compose file for a MySQL database. Mount a volume to persist database data.
- **Example**:

```yaml
version: '3.8'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
volumes:
  db_data:
```

[solution](docker-volumes/docker-compose.yaml)

## Custom Docker Images

- **Explanation**: You can customize Docker images by modifying their base configuration.
- **Task**: Build a custom Nginx image that serves a simple HTML page.
- **Example**:

```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
Dockerfile Optimizations
**Explanation**: A well-optimized Dockerfile reduces image size and improves build speed by leveraging caching and `.dockerignore`.
**Task**: Create a Dockerfile for a Python Flask app and optimize it.
**Example**:
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

[solution](custom-docker-image/Dockerfile)

## Container Health Checks

- **Explanation**: Health checks allow you to monitor container health by running periodic commands.
- **Task**: Add a health check to a Docker container running Nginx.
- **Example**:

```Dockerfile
FROM nginx:alpine
HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost || exit 1
```

[solution](container-health-checks/Dockerfile)

## Container Resource Limits

- **Explanation**: Docker allows you to set CPU and memory limits to ensure a container does not exhaust host resources.
- **Task**: Run a Python app with CPU and memory limits and - observe behavior when the limits are exceeded.
  **Example**:

```bash
docker run --memory=256m --cpus=1 python:3.9-slim python -c "while True: pass"
```

[solution](container-resource-limits/scripts/run.sh)

## Docker Compose for Multi-Service Apps

- **Explanation**: Docker Compose simplifies managing multi-container applications.
- **Task**: Use Docker Compose to define a Flask app and a Redis service for caching.
- **Example**:

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - '5000:5000'
  redis:
    image: redis:alpine
```

[solution](docker-compose-for-multi-service-apps/docker-compose.yaml)

## Docker Image Scanning

- **Explanation**: Security tools like `docker scan` or `trivy` identify vulnerabilities in images.
- **Task**: Scan the `nginx:alpine` image and resolve vulnerabilities.
- **Example**:

```bash
docker pull nginx:alpine
docker scan nginx:alpine
```

## Logs and Debugging

- **Explanation**: Docker logs and debugging tools help troubleshoot containerized applications.
- **Task**: Run a Flask app container, generate logs, and use `docker logs` to debug issues.
- **Example**:

```bash
docker run -d -p 5000:5000 flask-app
docker logs <container_id>
```
