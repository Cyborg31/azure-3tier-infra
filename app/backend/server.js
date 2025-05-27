const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;

const db = mysql.createConnection({
  host: process.env.DB_HOST || "127.0.0.1",
  user: 'root',
  password: '',
  database: 'appdb'
});

db.connect(err => {
  if (err) {
    console.error('DB connection error:', err);
    process.exit(1);
  }
  console.log('Connected to DB');
});

app.get('/api/hello', (req, res) => {
  db.query('SELECT message FROM messages LIMIT 1', (err, results) => {
    if (err) {
      res.status(500).send({error: err.message});
      return;
    }
    res.json({ message: results[0].message });
  });
});

app.listen(port, () => {
  console.log(`Backend listening at http://localhost:${port}`);
});
