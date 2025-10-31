const express = require('express');
const router = express.Router();
router.get('/', (req, res) => res.status(501).json({ msg: 'list donors - not implemented' }));
router.post('/', (req, res) => res.status(501).json({ msg: 'register donor - not implemented' }));
module.exports = router;
