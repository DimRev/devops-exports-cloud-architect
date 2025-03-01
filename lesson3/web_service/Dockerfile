FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

ENV WORKER_SERVICE_URI=http://127.0.0.1:5001

CMD ["python", "main.py"]