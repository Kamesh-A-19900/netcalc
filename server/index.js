const express = require('express');
const cors = require('cors');

const allocateRouter = require('./routes/allocate');
const subnetRouter = require('./routes/subnet');
const headerRouter = require('./routes/header');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.use('/api/allocate', allocateRouter);
app.use('/api/subnet', subnetRouter);
app.use('/api/header', headerRouter);

// Global error handler
app.use((err, req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`NetCal server running on http://localhost:${PORT}`);
});

module.exports = app;
