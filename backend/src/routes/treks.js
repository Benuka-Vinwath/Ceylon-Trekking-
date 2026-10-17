import { Router } from 'express';
import { pool } from '../db.js';

const router = Router();
const DIFFICULTIES = ['Easy', 'Moderate', 'Hard'];

// GET /api/treks?difficulty=Easy&q=ella  -> Home + Search screens
router.get('/', async (req, res, next) => {
  try {
    const where = [];
    const params = [];
    const { difficulty, q } = req.query;

    if (difficulty) {
      if (!DIFFICULTIES.includes(difficulty)) return res.status(400).json({ error: 'Invalid difficulty' });
      params.push(difficulty);
      where.push(`difficulty = $${params.length}`);
    }
    if (q) {
      params.push(`%${q}%`);
      where.push(`name ILIKE $${params.length}`);
    }

    // $1, $2 are placeholders: values travel separately from the SQL, which blocks SQL injection.
    const sql = `SELECT * FROM treks ${where.length ? 'WHERE ' + where.join(' AND ') : ''} ORDER BY name`;
    const { rows } = await pool.query(sql, params);
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/treks/:id -> Trek Details screen
router.get('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ error: 'Invalid id' });
    const { rows } = await pool.query('SELECT * FROM treks WHERE id = $1', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Trek not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

export default router;
