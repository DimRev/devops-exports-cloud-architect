import datetime
import logging

# Configure logging
logging.basicConfig(filename='/app/logs/cronjob.log', level=logging.INFO)

def log_message():
    current_time = datetime.datetime.now()
    message = f"CronJob executed at {current_time}"
    logging.info(message)
    return message

if __name__ == "__main__":
    log_message()