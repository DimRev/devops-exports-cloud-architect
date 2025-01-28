from flask import Flask, request, jsonify
from dotenv import load_dotenv
import mysql.connector
import os

app = Flask(__name__)

# Load environment variables
load_dotenv()

# Connect to the MySQL database
try:
    mydb = mysql.connector.connect(
        host=os.environ.get("MYSQL_HOST"),
        port=int(os.environ.get("MYSQL_PORT")),
        database=os.environ.get("MYSQL_DB"),
        user=os.environ.get("MYSQL_USER"),
        password=os.environ.get("MYSQL_ROOT_PASSWORD"),
    )
except mysql.connector.Error as err:
    print(f"Error: {err}")
    exit(1)


# Health check endpoint
@app.route("/healthz")
def healthz():
    return jsonify({"message": "OK!"})


# Get all todos
@app.route("/api/v1/todo", methods=["GET"])
def get_todos():
    qry = "SELECT * FROM todos"
    try:
        cursor = mydb.cursor(dictionary=True)
        cursor.execute(qry)
        rows = cursor.fetchall()
        return jsonify({"todos": rows}), 200
    except mysql.connector.Error as err:
        return jsonify({"error": f"Failed to fetch todos: {err}"}), 500


# Add a new todo
@app.route("/api/v1/todo", methods=["POST"])
def add_todo():
    qry = "INSERT INTO todos (title, description) VALUES (%s, %s)"
    try:
        title = request.json.get("title")
        description = request.json.get("description")

        if not title or not description:
            return jsonify({"error": "Title and description are required"}), 400

        cursor = mydb.cursor(dictionary=True)
        cursor.execute(qry, (title, description))
        mydb.commit()

        # Fetch the newly created todo
        todo_id = cursor.lastrowid
        cursor.execute("SELECT * FROM todos WHERE id = %s", (todo_id,))
        new_todo = cursor.fetchone()
        return jsonify(new_todo), 201
    except mysql.connector.Error as err:
        return jsonify({"error": f"Failed to add todo: {err}"}), 500


# Update a todo
@app.route("/api/v1/todo/<int:id>", methods=["PUT"])
def update_todo(id):
    qry = "UPDATE todos SET title = %s, description = %s WHERE id = %s"
    try:
        title = request.json.get("title")
        description = request.json.get("description")

        if not title or not description:
            return jsonify({"error": "Title and description are required"}), 400

        cursor = mydb.cursor(dictionary=True)
        cursor.execute(qry, (title, description, id))
        mydb.commit()

        if cursor.rowcount == 0:
            return jsonify({"error": f"Todo with id {id} not found"}), 404

        # Fetch the updated todo
        cursor.execute("SELECT * FROM todos WHERE id = %s", (id,))
        updated_todo = cursor.fetchone()
        return jsonify(updated_todo), 200
    except mysql.connector.Error as err:
        return jsonify({"error": f"Failed to update todo: {err}"}), 500


# Delete a todo
@app.route("/api/v1/todo/<int:id>", methods=["DELETE"])
def delete_todo(id):
    qry = "DELETE FROM todos WHERE id = %s"
    try:
        cursor = mydb.cursor()
        cursor.execute(qry, (id,))
        mydb.commit()

        if cursor.rowcount == 0:
            return jsonify({"error": f"Todo with id {id} not found"}), 404

        return jsonify({"deleted_id": id}), 200
    except mysql.connector.Error as err:
        return jsonify({"error": f"Failed to delete todo: {err}"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("SERVER_PORT", 5000)))
