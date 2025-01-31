FROM python:3.10-slim

WORKDIR /app


COPY requirements.txt .

RUN pip install -r requirements.txt


COPY . .

ENV MONGO_URI=mongodb://localhost:27017/testdb
ENV SERVER_PORT=5000

EXPOSE 5000

CMD ["python", "main.py"]