import os
from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
from bson.objectid import ObjectId

app = Flask(__name__)

# MongoDB Configuration
MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/testdb")
SERVER_PORT = os.environ.get("SERVER_PORT", 5000)

app.config["MONGO_URI"] = MONGO_URI

# Correct initialization for flask_pymongo >= 3.0.0
mongo = PyMongo()
mongo.init_app(app)

# Ensure connection
if mongo.db is None:
    raise Exception(f"Failed to connect to MongoDB. Check MONGO_URI and MongoDB server status, with {MONGO_URI}")

# Collection reference
collection = mongo.db.items

# Enable CORS
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Health Check Endpoint for Docker
@app.route("/healthz", methods=["GET"])
def healthz():
    return jsonify({"status": "healthy"}), 200

# Create a new item using ID from route param
@app.route("/api/items/<string:item_id>", methods=["POST"])
def create_item(item_id):
    data = request.json
    if not data or "name" not in data:
        return jsonify({"error": "Invalid data"}), 400

    # Ensure the ID is properly formatted as an ObjectId
    try:
        obj_id = ObjectId(item_id)
    except:
        return jsonify({"error": "Invalid item ID format"}), 400

    # Insert item with predefined ObjectId
    collection.insert_one({"_id": obj_id, "name": data["name"], "description": data.get("description", "")})
    return jsonify({"message": "Item created", "id": item_id}), 201

# Read all items
@app.route("/api/items", methods=["GET"])
def get_items():
    items = list(collection.find({}, {"_id": 1, "name": 1, "description": 1}))
    for item in items:
        item["_id"] = str(item["_id"])  # Convert ObjectId to string
    return jsonify(items), 200

# Read a single item by ID
@app.route("/api/items/<string:item_id>", methods=["GET"])
def get_item(item_id):
    try:
        obj_id = ObjectId(item_id)
        item = collection.find_one({"_id": obj_id})
        if not item:
            return jsonify({"error": "Item not found"}), 404

        item["_id"] = str(item["_id"])
        return jsonify(item), 200
    except:
        return jsonify({"error": "Invalid item ID format"}), 400

# Update an item using ID from route param
@app.route("/api/items/<string:item_id>", methods=["PUT"])
def update_item(item_id):
    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400

    try:
        obj_id = ObjectId(item_id)
        updated = collection.update_one({"_id": obj_id}, {"$set": data})
        if updated.matched_count == 0:
            return jsonify({"error": "Item not found"}), 404
        return jsonify({"message": "Item updated"}), 200
    except:
        return jsonify({"error": "Invalid item ID format"}), 400

# Delete an item
@app.route("/api/items/<string:item_id>", methods=["DELETE"])
def delete_item(item_id):
    try:
        obj_id = ObjectId(item_id)
        result = collection.delete_one({"_id": obj_id})
        if result.deleted_count == 0:
            return jsonify({"error": "Item not found"}), 404
        return jsonify({"message": "Item deleted"}), 200
    except:
        return jsonify({"error": "Invalid item ID format"}), 400

# Run the Flask app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=SERVER_PORT, debug=True)
