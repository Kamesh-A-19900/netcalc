const express = require('express');
const router = express.Router();
const { analyzeSubnet } = require('../lib/subnetCalculator');

router.post('/', (req, res) => {
  const { cidr } = req.body;
  if (!cidr) return res.status(400).json({ error: 'Request must include cidr (string)' });

  const result = analyzeSubnet(cidr);
  if (result.error) return res.status(400).json(result);
  return res.json(result);
});

module.exports = router;
