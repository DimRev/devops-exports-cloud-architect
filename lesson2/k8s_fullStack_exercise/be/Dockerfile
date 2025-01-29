FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENV MYSQL_HOST=db-host
ENV MYSQL_PORT=3306
ENV MYSQL_DB=db-name
ENV MYSQL_USER=db-use
ENV MYSQL_ROOT_PASSWORD=db-password

ENV SERVER_PORT=5000
ENV SERVER_API_KEY=1234567890

EXPOSE 5000

CMD ["python", "main.py"]