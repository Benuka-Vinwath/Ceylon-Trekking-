import jwt from 'jsonwebtoken';
import { pool } from './db.js';

export const signToken = (user) =>
  jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

// Middleware: runs before a protected route. Expects header "Authorization: Bearer <token>".
export function requireAuth(req, res, next) {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET); // { id, role }
    next();
  } catch {
    res.status(401).json({ error: 'Please log in' });
  }
}

// Admin status comes from the database, not the token: a token keeps its old role for 7 days.
export const isAdmin = async (userId) =>
  (await pool.query("SELECT 1 FROM users WHERE id = $1 AND role = 'admin'", [userId])).rows.length > 0;

// Middleware for admin-only routes. Use after requireAuth.
export async function requireAdmin(req, res, next) {
  try {
    if (await isAdmin(req.user.id)) return next();
    res.status(403).json({ error: 'Admins only' });
  } catch (err) {
    next(err);
  }
}
