import azure.functions as func
import logging
import pyodbc
import os
import json

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="getdata") 
def getdata(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    db_server = os.environ.get("DB_SERVER")
    db_name = os.environ.get("DB_NAME")
    db_user = os.environ.get("DB_USER")
    db_password = os.environ.get("DB_PASSWORD") 

    if not all([db_server, db_name, db_user, db_password]):
        logging.error("One or more DB connection settings are missing in app settings.")
        return func.HttpResponse(
            "DB connection settings missing. Ensure DB_SERVER, DB_NAME, DB_USER, DB_PASSWORD are set.",
            status_code=500
        )

    connection_string = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={db_server};"
        f"DATABASE={db_name};"
        f"UID={db_user};"
        f"PWD={db_password}"
    )

    cnxn = None 
    try:
        logging.info(f"Attempting to connect to DB: {db_server}/{db_name}")
        cnxn = pyodbc.connect(connection_string)
        cursor = cnxn.cursor()
        logging.info("Successfully connected to DB.")

        cursor.execute("SELECT id, message, created_at FROM messages_table ORDER BY id ASC")
        rows = cursor.fetchall()

        data = []
        columns = [column[0] for column in cursor.description]
        for row in rows:
            data.append(dict(zip(columns, row)))

        logging.info(f"Retrieved {len(data)} rows from messages_table.")
        return func.HttpResponse(
            json.dumps(data, default=str), 
            mimetype="application/json",
            status_code=200
        )

    except Exception as e:
        logging.error(f"Error connecting to DB or fetching data: {e}")
        return func.HttpResponse(
            f"Error: Could not retrieve data from database. Details: {e}",
            status_code=500
        )
    finally:
        if cnxn:
            cnxn.close()
            logging.info("Database connection closed.")