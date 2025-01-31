import os
import logging
from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
from bson.objectid import ObjectId

# Configure Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

app = Flask(__name__)

# MongoDB Configuration
MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/testdb")
SERVER_PORT = os.environ.get("SERVER_PORT", 5000)
SERVER_API_KEY = os.environ.get("SERVER_API_KEY", "my_api_key")

app.config["MONGO_URI"] = MONGO_URI

# Correct initialization for flask_pymongo >= 3.0.0
mongo = PyMongo()
mongo.init_app(app)

# Ensure connection
if mongo.db is None:
    logger.error(f"Failed to connect to MongoDB. Check MONGO_URI and MongoDB server status: {MONGO_URI}")
    raise Exception("Failed to connect to MongoDB")

# Collection reference
collection = mongo.db.items

# Enable CORS
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Health Check Endpoint
@app.route("/healthz", methods=["GET"])
def healthz():
    return jsonify({"status": "healthy"}), 200

# Create a new item
@app.route("/api/items", methods=["POST"])
def create_item():
    try:
        headers = request.headers
        if headers.get("X-API-KEY") != SERVER_API_KEY:
            return jsonify({"error": "Invalid API key"}), 401

        data = request.json
        if not data or "name" not in data:
            return jsonify({"error": "Invalid data"}), 400

        # Generate a new ObjectId
        new_item = {
            "_id": ObjectId(),
            "name": data["name"],
            "description": data.get("description", ""),
        }

        # Insert into collection
        collection.insert_one(new_item)

        logger.info(f"Item created: {new_item}")

        # Convert `_id` to string for JSON response
        new_item["_id"] = str(new_item["_id"])

        return jsonify({"message": "Item created", "item": new_item}), 201

    except Exception as e:
        logger.error(f"Error creating item: {e}", exc_info=True)
        return jsonify({"error": "Internal server error"}), 500


# Read all items
@app.route("/api/items", methods=["GET"])
def get_items():
    try:
        headers = request.headers
        if headers.get("X-API-KEY") != SERVER_API_KEY:
            return jsonify({"error": "Invalid API key"}), 401

        items = list(collection.find({}, {"_id": 1, "name": 1, "description": 1}))
        for item in items:
            item["_id"] = str(item["_id"])  # Convert ObjectId to string
        return jsonify(items), 200
    except Exception as e:
        logger.error(f"Error fetching items: {e}", exc_info=True)
        return jsonify({"error": "Internal server error"}), 500

# Read a single item by ID
@app.route("/api/items/<string:item_id>", methods=["GET"])
def get_item(item_id):
    try:
        headers = request.headers
        if headers.get("X-API-KEY") != SERVER_API_KEY:
            return jsonify({"error": "Invalid API key"}), 401

        obj_id = ObjectId(item_id)
        item = collection.find_one({"_id": obj_id})
        if not item:
            return jsonify({"error": "Item not found"}), 404

        item["_id"] = str(item["_id"])
        return jsonify(item), 200
    except Exception as e:
        logger.error(f"Error fetching item {item_id}: {e}", exc_info=True)
        return jsonify({"error": "Invalid item ID format"}), 400

# Update an item
@app.route("/api/items/<string:item_id>", methods=["PUT"])
def update_item(item_id):
    try:
        headers = request.headers
        if headers.get("X-API-KEY") != SERVER_API_KEY:
            return jsonify({"error": "Invalid API key"}), 401

        data = request.json
        if not data:
            return jsonify({"error": "No data provided"}), 400

        obj_id = ObjectId(item_id)
        updated = collection.update_one({"_id": obj_id}, {"$set": data})
        if updated.matched_count == 0:
            return jsonify({"error": "Item not found"}), 404

        # Fetch updated item
        updated_item = collection.find_one({"_id": obj_id})
        updated_item["_id"] = str(updated_item["_id"])  # Convert ObjectId to string

        logger.info(f"Item updated: {updated_item}")

        return jsonify({"message": "Item updated", "item": updated_item}), 200
    except Exception as e:
        logger.error(f"Error updating item {item_id}: {e}", exc_info=True)
        return jsonify({"error": "Invalid item ID format"}), 400


# Delete an item
@app.route("/api/items/<string:item_id>", methods=["DELETE"])
def delete_item(item_id):
    try:
        headers = request.headers
        if headers.get("X-API-KEY") != SERVER_API_KEY:
            return jsonify({"error": "Invalid API key"}), 401

        obj_id = ObjectId(item_id)
        result = collection.delete_one({"_id": obj_id})
        if result.deleted_count == 0:
            return jsonify({"error": "Item not found"}), 404

        logger.info(f"Item deleted: {item_id}")
        return jsonify({"message": "Item deleted"}), 200
    except Exception as e:
        logger.error(f"Error deleting item {item_id}: {e}", exc_info=True)
        return jsonify({"error": "Invalid item ID format"}), 400

# Run the Flask app
if __name__ == "__main__":
    logger.info("Starting Flask server...")
    app.run(host="0.0.0.0", port=SERVER_PORT, debug=True)
