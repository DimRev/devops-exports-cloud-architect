FROM python:3.11-slim

RUN apt update 
RUN apt upgrade -y
RUN apt-get install iputils-ping -y
RUN apt-get install curl -y

WORKDIR /app

COPY requirements.txt /app

RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

HEALTHCHECK --interval=5s --timeout=3s --start-period=10s \
  CMD curl -f http://localhost:5000/healthz || exit 1

EXPOSE 5000

CMD ["python", "app.py"]