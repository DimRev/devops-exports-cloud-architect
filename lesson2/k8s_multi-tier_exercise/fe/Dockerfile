# Build Stage
FROM node:22 AS builder

WORKDIR /app

RUN npm install -g pnpm
RUN npm install -g pnpm@10.0.0

COPY package.json .
COPY pnpm-lock.yaml .

RUN pnpm i

COPY . .

ENV VITE_API_URL=http://localhost:5000

RUN pnpm run build

FROM nginx:1.25

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/dist /usr/share/nginx/html
