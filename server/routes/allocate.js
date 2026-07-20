const express = require('express');
const router = express.Router();
const { allocateIpGroups } = require('../lib/ipAllocator');

router.post('/', (req, res) => {
  const { cidr, groups } = req.body;
  if (!cidr || !Array.isArray(groups))
    return res.status(400).json({ error: 'Request must include cidr (string) and groups (array)' });

  const result = allocateIpGroups(cidr, groups);
  if (result.error) return res.status(400).json(result);
  return res.json(result.allocations);
});

module.exports = router;
