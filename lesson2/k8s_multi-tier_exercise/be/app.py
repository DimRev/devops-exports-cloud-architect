import os
import redis
from flask import Flask, jsonify

app = Flask(__name__)

# Read Redis connection settings from environment variables
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_DB = int(os.getenv("REDIS_DB", 0))
SERVER_PORT = int(os.getenv("SERVER_PORT", 5000))


# Connect to Redis
try:
    redis_client = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
    redis_client.ping()  # Test the connection
    print("Connected to Redis successfully!")
except redis.ConnectionError:
    print("Failed to connect to Redis. Exiting...")
    exit(1)
except Exception as e:
    print(f"An error occurred: {e}")
    exit(1)
finally:
    redis_client = None

@app.route("/")
def index():
    return jsonify({"message": "Flask & Redis API is running!"})

@app.route("/set/<key>/<value>")
def set_value(key, value):
    if redis_client:
        redis_client.set(key, value)
        return jsonify({"message": f"Key '{key}' set to '{value}'"})
    return jsonify({"error": "Redis connection failed"}), 500

@app.route("/get/<key>")
def get_value(key):
    if redis_client:
        value = redis_client.get(key)
        if value:
            return jsonify({key: value})
        return jsonify({"error": f"Key '{key}' not found"}), 404
    return jsonify({"error": "Redis connection failed"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=SERVER_PORT, debug=True)
