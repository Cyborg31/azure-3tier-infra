import os
import logging
import pyodbc
import json
import azure.functions as func


def get_db_connection():
    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_NAME")
    username = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
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
    logging.info("getdata function triggered.")

    origin = req.headers.get("Origin", "*")

    if req.method == "OPTIONS":
        logging.info("CORS preflight request received.")
        return func.HttpResponse(
            status_code=204,
            headers={
                "Access-Control-Allow-Origin": origin,
                "Access-Control-Allow-Methods": "GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, x-functions-key",
                "Access-Control-Max-Age": "86400"
            }
        )

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT id, message, created_at FROM messages_table ORDER BY created_at DESC")
                rows = cursor.fetchall()

                data = []
                for row in rows:
                    data.append({
                        "id": row[0],
                        "message": row[1],
                        "created_at": row[2].isoformat()
                    })

        return func.HttpResponse(
            body=json.dumps(data),
            mimetype="application/json",
            status_code=200,
            headers={
                "Access-Control-Allow-Origin": origin
            }
        )

    except ValueError as ve:
        logging.exception(f"Configuration error in GetData: {ve}")
        return func.HttpResponse(
            "Internal Server Error: Database configuration incomplete.",
            status_code=500,
            headers={
                "Access-Control-Allow-Origin": origin
            }
        )

    except pyodbc.Error as db_err:
        logging.exception(f"Database error in GetData: {db_err}")
        return func.HttpResponse(
            f"Internal Server Error: Database operation failed. Details: {db_err}",
            status_code=500,
            headers={
                "Access-Control-Allow-Origin": origin
            }
        )

    except Exception as e:
        logging.exception(f"Unexpected error in GetData: {e}")
        return func.HttpResponse(
            f"Internal Server Error: Unexpected error occurred. Details: {e}",
            status_code=500,
            headers={
                "Access-Control-Allow-Origin": origin
            }
        )