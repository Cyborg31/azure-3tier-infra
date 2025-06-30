import os
import logging
import pyodbc
import json
import azure.functions as func

# --- Helper function for DB connection (recommended for reuse) ---
def get_db_connection():
    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_NAME")
    username = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    # Get driver from env var, fallback to default if not set
    driver = os.getenv("DB_DRIVER", "{ODBC Driver 18 for SQL Server}")

    if not all([server, database, username, password]):
        logging.exception("Missing one or more database environment variables (SERVER, NAME, USER, PASSWORD).")
        raise ValueError("Database configuration incomplete.")

    conn_str = (
        f'DRIVER={driver};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'UID={username};'
        f'PWD={password};'
        'Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;'
    )
    return pyodbc.connect(conn_str)

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("GetData function triggered.")

    try:
        with get_db_connection() as conn: # Use the helper function
            with conn.cursor() as cursor:
                # Added ORDER BY for consistent results
                cursor.execute("SELECT id, message, created_at FROM messages_table ORDER BY created_at DESC")
                rows = cursor.fetchall()

                data = []
                for row in rows:
                    data.append({
                        "id": row[0],
                        "message": row[1],
                        "created_at": row[2].isoformat() # Convert datetime to ISO 8601 string
                    })

        return func.HttpResponse(
            body=json.dumps(data),
            mimetype="application/json",
            status_code=200
        )

    except ValueError as ve: # Catch specific config errors
        logging.exception(f"Configuration error in GetData: {ve}")
        return func.HttpResponse("Internal Server Error: Database configuration incomplete.", status_code=500)
    except pyodbc.Error as db_err: # Catch specific DB errors
        logging.exception(f"Database error in GetData: {db_err}")
        return func.HttpResponse(f"Internal Server Error: Database operation failed. Details: {db_err}", status_code=500)
    except Exception as e: # Catch any other unexpected errors
        logging.exception(f"An unexpected error occurred in GetData: {e}")
        return func.HttpResponse(f"Internal Server Error: An unexpected error occurred. Details: {e}", status_code=500)