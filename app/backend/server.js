const express = require('express');
const db = require('./db');

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  db.query('SELECT * FROM users', (err, results) => {
    if (err) return res.status(500).send('DB Error');
    res.json(results);
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Backend listening at http://0.0.0.0:${port}`);
});
