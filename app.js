const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const app = express();

app.use([
  morgan('short'),
  cors({
    origin: '*',
    methods: 'GET',
    allowedHeaders: '*',
    exposedHeaders: '*'
  })
]);

app.get('/', (req, res) => {
  const { url, method, headers } = req;
  res.status(200).json({ url, method, headers });
});

const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(':: Listening on port ', port);
});
