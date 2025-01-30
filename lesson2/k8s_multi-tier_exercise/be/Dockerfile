FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENV REDIS_HOST=my-redis
ENV REDIS_PORT=6379
ENV REDIS_DB=0

ENV SERVER_PORT=5000

EXPOSE 5000

CMD ["python", "app.py"]