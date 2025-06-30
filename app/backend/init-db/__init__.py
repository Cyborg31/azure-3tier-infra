import os
import logging
import pyodbc
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Init-DB function triggered")

    api_key = req.params.get("key")
    expected_key = os.getenv("ADMIN_API_KEY")

    if not api_key or api_key != expected_key:
        logging.warning("Unauthorized request")
        return func.HttpResponse("Unauthorized", status_code=401)

    # DB config from environment
    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_NAME")
    username = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    driver = '{ODBC Driver 18 for SQL Server}'

    # SQL script
    sql_script = """
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'messages_table')
    BEGIN
        CREATE TABLE messages_table (
            id INT PRIMARY KEY IDENTITY(1,1),
            message NVARCHAR(255) NOT NULL,
            created_at DATETIME DEFAULT GETDATE()
        )
    END

    IF NOT EXISTS (SELECT 1 FROM messages_table WHERE message = 'Hello from Azure SQL Database!')
    BEGIN
        INSERT INTO messages_table (message) VALUES ('Hello from Azure SQL Database!');
        INSERT INTO messages_table (message) VALUES ('This data is served by Azure Function!');
    END
    """

    try:
        with pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;') as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql_script)
                conn.commit()
        return func.HttpResponse("Database initialized", status_code=200)
    except Exception as e:
        logging.error(f"DB init failed: {e}")
        return func.HttpResponse(f"Error: {e}", status_code=500)