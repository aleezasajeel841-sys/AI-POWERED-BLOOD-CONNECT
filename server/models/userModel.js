// server/models/userModel.js
const pool = require('../db/pool');

async function findUserByEmail(email) {
  const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
  return rows[0];
}

async function createUser({ role_id, name, email, password_hash, phone, city }) {
  const [result] = await pool.query(
    `INSERT INTO users (role_id, name, email, password_hash, phone, city) VALUES (?, ?, ?, ?, ?, ?)`,
    [role_id, name, email, password_hash, phone || null, city || null]
  );
  return { id: result.insertId, role_id, name, email, phone, city };
}

module.exports = {
  findUserByEmail,
  createUser,
};