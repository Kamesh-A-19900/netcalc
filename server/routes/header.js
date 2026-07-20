const express = require('express');
const router = express.Router();
const { analyzeHeader } = require('../lib/headerAnalyzer');

router.post('/', (req, res) => {
  const { header } = req.body;
  if (!header) return res.status(400).json({ error: 'Request must include header (string)' });

  const result = analyzeHeader(header);
  if (result.error) return res.status(400).json(result);
  return res.json(result);
});

module.exports = router;
