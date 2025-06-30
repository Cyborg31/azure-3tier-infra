import os
import logging
import pyodbc
import azure.functions as func

logger = logging.getLogger(__name__)

def main(req: func.HttpRequest) -> func.HttpResponse:
    logger.info("Init-DB function received a request.")

    api_key = req.params.get("key")
    expected_key = os.getenv("ADMIN_API_KEY")

    logger.info(f"DEBUG: Received API key (repr): {repr(api_key)}")
    logger.info(f"DEBUG: Expected ADMIN_API_KEY (first 5 chars): {repr(expected_key[:5]) if expected_key else 'None'}, Full length: {len(expected_key) if expected_key else 0}")


    if not api_key:
        logger.warning("Unauthorized: API key not provided in request.")
        return func.HttpResponse("Unauthorized: API key not provided.", status_code=401)

    if api_key != expected_key:
        logger.warning(f"Unauthorized: Mismatching API key. Provided: {repr(api_key)}, Expected: {repr(expected_key)}")
        return func.HttpResponse("Unauthorized: Invalid API key.", status_code=401)
    
    logger.info("API key authenticated successfully.")


    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_NAME")
    username = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    driver = '{ODBC Driver 18 for SQL Server}'

    logger.info(f"DB_SERVER: {'Set' if server else 'NOT SET'}")
    logger.info(f"DB_NAME: {'Set' if database else 'NOT SET'}")
    logger.info(f"DB_USER: {'Set' if username else 'NOT SET'}")

    if not all([server, database, username, password]):
        missing_vars = [name for name, value in [("DB_SERVER", server), ("DB_NAME", database), ("DB_USER", username), ("DB_PASSWORD", password)] if not value]
        error_msg = f"Missing one or more database environment variables: {', '.join(missing_vars)}. Cannot connect to DB."
        logger.error(error_msg)
        return func.HttpResponse(f"Error: {error_msg}", status_code=500)

    sql_script = """
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'messages_table')
    BEGIN
        CREATE TABLE messages_table (
            id INT PRIMARY KEY IDENTITY(1,1),
            message NVARCHAR(255) NOT NULL,
            created_at DATETIME DEFAULT GETDATE()
        )
    END;

    IF NOT EXISTS (SELECT 1 FROM messages_table WHERE message = 'Hello from Azure SQL Database!')
    BEGIN
        INSERT INTO messages_table (message) VALUES ('Hello from Azure SQL Database!');
    END;

    IF NOT EXISTS (SELECT 1 FROM messages_table WHERE message = 'This data is served by Azure Function!')
    BEGIN
        INSERT INTO messages_table (message) VALUES ('This data is served by Azure Function!');
    END;
    """

    try:
        connection_string = (
            f'DRIVER={driver};'
            f'SERVER={server};'
            f'DATABASE={database};'
            f'UID={username};'
            f'PWD={password};'
            'Encrypt=yes;'
            'TrustServerCertificate=no;'
            'Connection Timeout=30;'
        )
        logger.info("Attempting to connect to the database...")
        
        with pyodbc.connect(connection_string) as conn:
            logger.info("Database connection established.")
            with conn.cursor() as cursor:
                logger.info("Executing SQL script...")
                cursor.execute(sql_script)
                conn.commit()
                logger.info("SQL script executed and committed successfully.")
        
        return func.HttpResponse("Database initialized successfully.", status_code=200)

    except pyodbc.Error as db_error:
        sql_state = db_error.args[0]
        error_message = db_error.args[1]
        logger.error(f"Database error (SQLSTATE: {sql_state}): {error_message}", exc_info=True)
        return func.HttpResponse(f"Database initialization failed: {error_message}", status_code=500)

    except Exception as e:
        logger.error(f"An unexpected error occurred during database initialization: {e}", exc_info=True)
        return func.HttpResponse(f"An unexpected error occurred: {e}", status_code=500)