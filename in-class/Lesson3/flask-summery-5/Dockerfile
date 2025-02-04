# Best practices:
# Always define the image version! It will save you debugging time.
FROM python:3.9-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV DB_HOST=localhost
ENV DB_NAME=mydatabase
ENV DB_USER=myuser
ENV DB_PASSWORD=mypassword

CMD ["python", "app.py"]
