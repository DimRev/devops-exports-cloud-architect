import os
import redis
import logging
from flask import Flask, jsonify
from flask_cors import CORS
# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

app = Flask(__name__)

CORS(app, resources={r"/*": {"origins": "*"}})

# Read Redis connection settings from environment variables
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_DB = int(os.getenv("REDIS_DB", 0))
SERVER_PORT = int(os.getenv("SERVER_PORT", 5000))

redis_client = None

# Connect to Redis
try:
    redis_client = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
    redis_client.ping()  # Test the connection
    logging.info("Connected to Redis successfully!")
except redis.ConnectionError as e:
    logging.error(f"Failed to connect to Redis: {e}")
    exit(1)
except Exception as e:
    logging.error(f"An unexpected error occurred while connecting to Redis: {e}")
    exit(1)


@app.route("/")
def index():
    return jsonify({"message": "Flask & Redis API is running!"})


@app.route("/set/<key>/<value>")
def set_value(key, value):
    if not redis_client:
        logging.error("Redis connection is not available.")
        return jsonify({"error": "Redis connection failed"}), 500

    try:
        redis_client.set(key, value)
        logging.info(f"Successfully set key '{key}' to '{value}' in Redis.")
        return jsonify({"message": f"Key '{key}' set to '{value}'"})
    except Exception as e:
        logging.error(f"Error setting key '{key}': {e}")
        return jsonify({"error": "Failed to set key in Redis"}), 500


@app.route("/get/<key>")
def get_value(key):
    if not redis_client:
        logging.error("Redis connection is not available.")
        return jsonify({"error": "Redis connection failed"}), 500

    try:
        value = redis_client.get(key)
        if value:
            logging.info(f"Successfully retrieved key '{key}' with value '{value}'.")
            return jsonify({key: value})
        logging.warning(f"Key '{key}' not found in Redis.")
        return jsonify({"error": f"Key '{key}' not found"}), 404
    except Exception as e:
        logging.error(f"Error retrieving key '{key}': {e}")
        return jsonify({"error": "Failed to retrieve key from Redis"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=SERVER_PORT, debug=True)
