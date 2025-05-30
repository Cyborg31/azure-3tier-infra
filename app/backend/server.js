const express = require('express');
const mysql = require('mysql');
const app = express();

const dbHost = process.env.DB_HOST || 'localhost';

const connection = mysql.createConnection({
  host: dbHost,
  user: 'root',
  password: '', // Adjust if you set MySQL root password
  database: 'appdb',
});

connection.connect(err => {
  if (err) {
    console.error('DB connection error:', err);
  } else {
    console.log('Connected to MySQL DB');
  }
});

app.use(express.static('../frontend')); // For testing serve frontend too (optional)

app.get('/api/db-status', (req, res) => {
  connection.query('SELECT 1', (err, results) => {
    if (err) {
      return res.json({ status: 'DB connection failed' });
    }
    res.json({ status: 'DB connected successfully' });
  });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Backend API listening on port ${PORT}`);
});
