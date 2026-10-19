import { Router } from 'express';
import { pool } from '../db.js';

const router = Router();
const DIFFICULTIES = ['Easy', 'Moderate', 'Hard'];

// LEFT JOIN keeps treks that have no reviews yet (their rating is null, count is 0).
const WITH_RATINGS = `SELECT t.*, ROUND(AVG(r.rating), 1)::float AS avg_rating, COUNT(r.id)::int AS review_count
  FROM treks t LEFT JOIN reviews r ON r.trek_id = t.id`;

// GET /api/treks?difficulty=Easy&q=ella  -> Home + Search screens
router.get('/', async (req, res, next) => {
  try {
    const where = [];
    const params = [];
    const { difficulty, q, region } = req.query;

    if (difficulty) {
      if (!DIFFICULTIES.includes(difficulty)) return res.status(400).json({ error: 'Invalid difficulty' });
      params.push(difficulty);
      where.push(`difficulty = $${params.length}`);
    }
    if (q) {
      params.push(`%${q}%`);
      where.push(`name ILIKE $${params.length}`);
    }
    if (region) {
      params.push(region);
      where.push(`region = $${params.length}`);
    }

    // $1, $2 are placeholders: values travel separately from the SQL, which blocks SQL injection.
    const order = req.query.sort === 'top_rated' ? 'avg_rating DESC NULLS LAST, name' : 'name';
    const sql = `${WITH_RATINGS} ${where.length ? 'WHERE ' + where.join(' AND ') : ''} GROUP BY t.id ORDER BY ${order}`;
    const { rows } = await pool.query(sql, params);
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/treks/:id/route -> Live Navigation: the waypoints in walking order
router.get('/:id/route', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ error: 'Invalid id' });
    const { rows } = await pool.query('SELECT position, name, lat, lng, elevation_m FROM trek_waypoints WHERE trek_id = $1 ORDER BY position', [id]);
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
    const { rows } = await pool.query(`${WITH_RATINGS} WHERE t.id = $1 GROUP BY t.id`, [id]);
    if (!rows.length) return res.status(404).json({ error: 'Trek not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

export default router;
