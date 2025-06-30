import os
import logging
import pyodbc
import azure.functions as func
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("GetData function triggered")

    api_key = req.params.get("key")
    expected_key = os.getenv("ADMIN_API_KEY")

    if not api_key or api_key != expected_key:
        logging.warning("Unauthorized request to getdata")
        return func.HttpResponse("Unauthorized", status_code=401)

    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_NAME")
    username = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    driver = '{ODBC Driver 18 for SQL Server}'

    try:
        with pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;') as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT id, message, created_at FROM messages_table")
                rows = cursor.fetchall()
                data = [
                    {"id": row[0], "message": row[1], "created_at": row[2].isoformat()}
                    for row in rows
                ]
        return func.HttpResponse(json.dumps(data), mimetype="application/json", status_code=200)
    except Exception as e:
        logging.error(f"Error reading DB: {e}")
        return func.HttpResponse(f"Error: {e}", status_code=500)
