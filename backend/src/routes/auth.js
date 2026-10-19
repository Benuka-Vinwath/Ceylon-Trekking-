import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import bcrypt from 'bcryptjs';
import { pool } from '../db.js';
import { signToken, requireAuth } from '../auth.js';

const router = Router();

// Slows down password guessing: 20 tries per 15 minutes per address, then "429 Too Many Requests".
// shortcut: counted in this server's memory, so it resets on restart and is not shared between several servers; use a shared store (e.g. Redis) when scaling out.
const limiter = rateLimit({ windowMs: 15 * 60 * 1000, limit: 20, standardHeaders: true, legacyHeaders: false, message: { error: 'Too many attempts, try again later' } });
const publicUser = ({ id, full_name, email, role }) => ({ id, full_name, email, role });

// POST /api/auth/signup  body: { full_name, email, password, role? } -> Sign Up screen
router.post('/signup', limiter, async (req, res, next) => {
  try {
    const { full_name, email, password, role = 'trekker' } = req.body;
    if (!full_name || !/^\S+@\S+\.\S+$/.test(email || '')) return res.status(400).json({ error: 'Name and valid email required' });
    if (typeof password !== 'string' || password.length < 8) return res.status(400).json({ error: 'Password must be at least 8 characters' });
    if (!['trekker', 'shop_owner'].includes(role)) return res.status(400).json({ error: 'Invalid role' }); // admins are never self-created

    const hash = await bcrypt.hash(password, 10);
    const { rows } = await pool.query(
      'INSERT INTO users (full_name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING *',
      [full_name, email.toLowerCase(), hash, role]
    );
    res.status(201).json({ token: signToken(rows[0]), user: publicUser(rows[0]) });
  } catch (err) {
    if (err.code === '23505') return res.status(409).json({ error: 'Email already registered' }); // UNIQUE violated
    next(err);
  }
});

// POST /api/auth/login  body: { email, password } -> Login screen
router.post('/login', limiter, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const { rows } = await pool.query('SELECT * FROM users WHERE email = $1', [String(email || '').toLowerCase()]);
    const ok = rows.length && (await bcrypt.compare(String(password || ''), rows[0].password_hash));
    // Same message for wrong email and wrong password, so attackers can't find which emails exist.
    if (!ok) return res.status(401).json({ error: 'Wrong email or password' });
    res.json({ token: signToken(rows[0]), user: publicUser(rows[0]) });
  } catch (err) {
    next(err);
  }
});

// GET /api/auth/me -> proves the token works; Profile screen will use it
router.get('/me', requireAuth, async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
    if (!rows.length) return res.status(401).json({ error: 'Please log in' });
    res.json(publicUser(rows[0]));
  } catch (err) {
    next(err);
  }
});

export default router;
