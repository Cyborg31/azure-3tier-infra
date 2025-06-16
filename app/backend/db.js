const mysql = require('mysql');

const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'nodeuser',
  password: process.env.DB_PASS || 'yourpassword',
  database: process.env.DB_NAME || 'nodeapp'
});

db.connect(err => {
  if (err) {
    console.error('Database connection failed:', err.stack);
    return;
  }
  console.log('Connected to database.');

  const createTable = `
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL
    )
  `;
  db.query(createTable, (err) => {
    if (err) throw err;
    console.log('Users table ready');

    const insertSample = `
      INSERT INTO users (name)
      SELECT * FROM (SELECT 'Alice') AS tmp
      WHERE NOT EXISTS (SELECT * FROM users WHERE name = 'Alice')
      LIMIT 1
    `;
    db.query(insertSample, (err) => {
      if (err) throw err;
      console.log('Sample data inserted');
    });
  });
});

module.exports = db;
