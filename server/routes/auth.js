const express = require('express');
const router = express.Router();
router.post('/signup', (req, res) => res.status(501).json({ msg: 'not implemented' }));
router.post('/login', (req, res) => res.status(501).json({ msg: 'not implemented' }));
module.exports = router;
