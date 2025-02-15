from flask import Flask, request, jsonify
import os

app = Flask(__name__)
data_file = "/data/data.txt"

@app.route('/')
def home():
    return "Welcome to the Flask App with Persistent Storage!"

@app.route('/write', methods=['POST'])
def write_data():
    content = request.json.get('content')
    with open(data_file, 'a') as f:
        f.write(content + '\n')
    return jsonify({"message": "Data written to file"}), 200

@app.route('/read', methods=['GET'])
def read_data():
    if os.path.exists(data_file):
        with open(data_file, 'r') as f:
            content = f.readlines()
        return jsonify({"data": content}), 200
    else:
        return jsonify({"message": "No data found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)