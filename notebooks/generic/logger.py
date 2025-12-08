import os

def log_message(file_path, message, level="ERROR"):
    """
    Logs a message to error_log.txt with a specified log level. Creates or overwrites the log file if it doesn't exist.

    Parameters:
        file_path (str): Path to the file being processed.
        message (str): The message to log.
        level (str): The log level (e.g., "ERROR", "WARNING", "DEBUG"). Default is "ERROR".
    """
    log_file = "log.txt"
    # Ensure the file is created or overwritten
    if not os.path.exists(log_file):
        with open(log_file, "w") as log:
            log.write("Error Log Initialized\n")

    with open(log_file, "a") as log:
        log.write(f"[{level}] {file_path}: {message}\n")

# Update log_error to use log_message
def log_error(file_path, error):
    log_message(file_path, str(error), level="ERROR")
