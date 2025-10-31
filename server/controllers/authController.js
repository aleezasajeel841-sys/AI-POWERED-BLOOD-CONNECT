// server/controllers/authController.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const userModel = require('../models/userModel');

const JWT_SECRET = process.env.JWT_SECRET || 'changeme';
const JWT_EXPIRES_IN = '7d';

async function signup(req, res) {
  try {
    const { name, email, password, phone, city, role } = req.body;
    if (!email || !password || !name || !role) {
      return res.status(400).json({ message: 'name, email, password and role are required' });
    }

    const existing = await userModel.findUserByEmail(email);
    if (existing) return res.status(409).json({ message: 'Email already registered' });

    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // role should be numeric role_id; caller can pass role_id or role name mapping handled elsewhere
    const role_id = Number(role) || 3; // default to donor (3) if role not numeric

    const user = await userModel.createUser({ role_id, name, email, password_hash, phone, city });

    const token = jwt.sign({ userId: user.id, role_id: role_id, email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    res.status(201).json({ message: 'User created', user: { id: user.id, name: user.name, email: user.email }, token });
  } catch (err) {
    console.error('signup error', err);
    res.status(500).json({ message: 'Internal server error' });
  }
}

async function login(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'email and password are required' });

    const user = await userModel.findUserByEmail(email);
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(401).json({ message: 'Invalid credentials' });

    const token = jwt.sign({ userId: user.id, role_id: user.role_id, email: user.email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    res.json({ message: 'Login successful', token });
  } catch (err) {
    console.error('login error', err);
    res.status(500).json({ message: 'Internal server error' });
  }
}

module.exports = { signup, login };