FROM nginx:latest

RUN apt update 
RUN apt upgrade -y
RUN apt-get install iputils-ping -y

COPY index.html /usr/share/nginx/html

EXPOSE 80