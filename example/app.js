const express = require('express');
const morgan = require('morgan');

const app = express();
app.use([ morgan('combined') ]);

app.get(/.*/, (req, res) => {
  const { url, method, headers } = req;
  res.status(200).json({ url, method, headers });
});

const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(`[app.js] Listening on port ${port}`);
});
