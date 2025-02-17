from flask import Flask
import time

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, Kubernetes!"

@app.route("/cpu")
def cpu_load():
    # Simulates CPU load by running a loop for a few seconds
    start_time = time.time()
    while time.time() - start_time < 2:
        pass
    return "CPU load simulated"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)