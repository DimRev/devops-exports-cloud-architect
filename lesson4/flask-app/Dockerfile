FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt /app

RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

RUN mkdir -p /app/logs && chmod -R 777 /app/logs

CMD ["python", "main.py"]
