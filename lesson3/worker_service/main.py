from flask import Flask, request, jsonify
from utils import reverse_string, count_words

app = Flask(__name__)

@app.route('/healthz')
def healthz():
    return 'OK!'


@app.route('/process', methods=['POST'])
def worker_service():
    body = request.get_json()

    # Check for text field in body
    if 'text' not in body:
        return 'Malformed request', 400

    reversed_text = reverse_string(body['text'])
    words_count = count_words(body['text'])

    resp = {
        'words_count': words_count,
        'reversed_text': reversed_text,
        }

    return jsonify(resp), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)