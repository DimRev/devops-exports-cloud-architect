from flask import Flask, request, jsonify
import psycopg2
import os

app = Flask(_name_)

def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )
    return conn

@app.route('/')
def index():
    return "Hello, World!"

@app.route('/add', methods=['POST'])
def add_entry():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO entries (content) VALUES (%s)", (data['content'],))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "success"}), 201

@app.route('/entries', methods=['GET'])
def get_entries():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM entries")
    entries = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(entries)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)