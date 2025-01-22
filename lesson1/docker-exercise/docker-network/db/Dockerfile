FROM postgres:latest

RUN apt update 
RUN apt upgrade -y
RUN apt-get install iputils-ping -y

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=mydb

EXPOSE 5432