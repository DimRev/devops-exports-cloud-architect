import os
import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

# Get the worker service URL from environment variables (set this in your Kubernetes deployment)
WORKER_SERVICE_URI = os.environ.get('WORKER_SERVICE_URI', 'http://127.0.0.1:5001')

@app.route('/healthz')
def healthz():
    return 'OK!'

@app.route('/analyze', methods=['POST'])
def web_service():
    body = request.get_json()

    # Validate input
    if 'text' not in body:
        return jsonify({'error': 'Malformed request, missing "text" field'}), 400

    # Send the text to worker-service
    try:
        worker_response = requests.post(
            f"{WORKER_SERVICE_URI}/process",
            json={'text': body['text']}
        )

        if worker_response.status_code != 200:
            print(f"Error processing text: {worker_response.text}")
            return jsonify({'error': 'Error processing text'}), worker_response.status_code

        worker_data = worker_response.json()
        words_count = worker_data.get('words_count', 0)
        reversed_text = worker_data.get('reversed_text', '')

        processed_text = f"Words count: {words_count} | Reversed: {reversed_text}"

        return jsonify({'processed_text': processed_text}), 200

    except requests.exceptions.RequestException as e:
        return jsonify({'error': f'Failed to reach worker-service: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
