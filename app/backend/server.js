// app/backend/server.js
const express = require('express');
const mysql = require('mysql');
const app = express();

// Use environment variables for all DB connection details
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',           // From Ansible Environment=DB_HOST
  user: process.env.DB_USER || 'root',               // From Ansible Environment=DB_USER (nodejs_app_user)
  password: process.env.DB_PASSWORD || '',           // From Ansible Environment=DB_PASSWORD (vaulted)
  database: process.env.DB_NAME || 'appdb',          // From Ansible Environment=DB_NAME
};

const connection = mysql.createConnection(dbConfig);

connection.connect(err => {
  if (err) {
    console.error('DB connection error:', err);
    // In a real application, you might want to exit or retry here if DB is essential
    // process.exit(1);
  } else {
    console.log('Connected to MySQL DB');
  }
});

app.get('/api/db-status', (req, res) => {
  connection.query('SELECT 1', (err, results) => {
    if (err) {
      // Provide more specific error for debugging
      return res.status(500).json({ status: 'DB connection failed', error: err.message });
    }
    res.json({ status: 'DB connected successfully' });
  });
});

const PORT = process.env.PORT || 3000; // Allow PORT to be configurable via env var too
app.listen(PORT, () => {
  console.log(`Backend API listening on port ${PORT}`);
});