FROM python:3.11-slim

RUN apt update 
RUN apt upgrade -y
RUN apt-get install iputils-ping -y

WORKDIR /app

COPY requirements.txt /app

RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

EXPOSE 5000

CMD ["python", "app.py"]