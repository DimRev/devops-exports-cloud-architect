import logging
import os
import re
from flask import Flask, render_template_string, Response

# Load environment variables from Kubernetes ConfigMap and Secret
APP_ENV = os.getenv("APP_ENV", "production")  # Default to 'production'
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()  # Default to 'INFO'
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

# Convert LOG_LEVEL to an actual logging level
LOG_LEVEL = getattr(logging, LOG_LEVEL, logging.INFO)

# Ensure log directory exists
LOG_DIR = "/app/logs"
LOG_FILE = os.path.join(LOG_DIR, "app.log")

if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR, exist_ok=True)

# Configure logging to file and console
logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, mode="a"),  # Append to file
        logging.StreamHandler(),  # Print logs to console
    ],
)

logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route("/")
def index():
    logger.info("Index route accessed")
    return render_template_string(
        f"""
    <h1>Hello, World!</h1>
    <p>Environment: {APP_ENV}</p>
    <p>Log Level: {LOG_LEVEL}</p>
    <p>Database Password Length: {"*" * len(DB_PASSWORD)}</p> <!-- Masked for security -->
    """
    )

@app.route("/healthz")
def healthz():
    logger.info("Healthz route accessed")
    return "OK"

def remove_ansi_escape_codes(text):
    """Removes ANSI escape codes (e.g., color codes) from logs."""
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

@app.route("/logs")
def logs():
    logger.info("Logs route accessed")
    try:
        with open(LOG_FILE, "r") as f:
            log_data = f.readlines()
        # Remove ANSI codes and wrap logs in HTML formatting
        formatted_logs = "<br>".join(remove_ansi_escape_codes(line) for line in log_data)
        return Response(f"<pre>{formatted_logs}</pre>", mimetype="text/html")
    except Exception as e:
        return f"Error reading log file: {str(e)}", 500

if __name__ == "__main__":
    logger.info("Starting Flask server")
    app.run(host="0.0.0.0", port=5000)  # Bind to all interfaces for container use
