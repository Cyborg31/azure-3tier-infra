IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='messages_table' and xtype='U')
BEGIN
    CREATE TABLE messages_table (
        id INT PRIMARY KEY IDENTITY(1,1),
        message NVARCHAR(255) NOT NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
    PRINT 'Table messages_table created.';
END;
ELSE
BEGIN
    PRINT 'Table messages_table already exists. Skipping creation.';
END;

-- Check if data exists before inserting to prevent duplicates on re-runs
IF NOT EXISTS (SELECT * FROM messages_table WHERE message = 'Hello from Azure SQL Database!')
BEGIN
    INSERT INTO messages_table (message) VALUES ('Hello from Azure SQL Database!');
    INSERT INTO messages_table (message) VALUES ('This data is served by Azure Function!');
    PRINT 'Initial data inserted into messages_table.';
END;
ELSE
BEGIN
    PRINT 'Initial data already exists. Skipping insertion.';
END;