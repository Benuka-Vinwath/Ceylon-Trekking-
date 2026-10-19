import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth } from '../auth.js';
import { parseId } from '../util.js';
import { validate } from '../validate.js';

const router = Router();
router.use(requireAuth); // every route here is about "my" hikes

const HIKE = {
  trek_id: ['int', { min: 1 }],
  distance_km: ['num', { min: 0.01, max: 500 }],
  duration_seconds: ['int', { min: 1, max: 7 * 86400 }],
  elevation_gain_m: ['int', { min: 0, max: 9000, optional: true }],
  started_at: ['text'],
};
const MAX_POINTS = 5000;

// The recorded path must be a list of [lat, lng] points.
const validPath = (p) =>
  Array.isArray(p) && p.length <= MAX_POINTS &&
  p.every((pt) => Array.isArray(pt) && pt.length === 2 && Math.abs(pt[0]) <= 90 && Math.abs(pt[1]) <= 180 && pt.every(Number.isFinite));

// Pace is worked out when asked (minutes per km), not stored.
const SUMMARY = `h.id, h.trek_id, t.name AS trek_name, h.distance_km, h.duration_seconds, h.elevation_gain_m, h.started_at,
  ROUND((h.duration_seconds / 60.0) / h.distance_km, 1)::float AS avg_pace_min_per_km`;

// POST /api/hikes -> "Finish" on Live Navigation. Body: { trek_id, distance_km, duration_seconds, elevation_gain_m?, started_at, path? }
router.post('/', async (req, res, next) => {
  try {
    const { path = [], ...rest } = req.body ?? {};
    const { values, error } = validate(HIKE, rest);
    if (error) return res.status(400).json({ error });
    const started = new Date(values.started_at);
    if (isNaN(started) || started > Date.now() + 5 * 60 * 1000) return res.status(400).json({ error: 'started_at must be a date in the past' });
    if (!validPath(path)) return res.status(400).json({ error: `path must be a list of up to ${MAX_POINTS} [lat, lng] points` });

    const { rows } = await pool.query(
      `INSERT INTO hikes (user_id, trek_id, distance_km, duration_seconds, elevation_gain_m, started_at, path)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
      [req.user.id, values.trek_id, values.distance_km, values.duration_seconds, values.elevation_gain_m ?? 0, started.toISOString(), JSON.stringify(path)]
    );
    const saved = await pool.query(`SELECT ${SUMMARY} FROM hikes h JOIN treks t ON t.id = h.trek_id WHERE h.id = $1`, [rows[0].id]);
    res.status(201).json(saved.rows[0]);
  } catch (err) {
    if (err.code === '23503') return res.status(404).json({ error: 'Trek not found' });
    next(err);
  }
});

// GET /api/hikes/stats -> the numbers on the Profile screen
router.get('/stats', async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT (SELECT count(*) FROM hikes WHERE user_id = $1)::int AS treks,
              (SELECT COALESCE(SUM(distance_km), 0) FROM hikes WHERE user_id = $1)::float AS distance_km,
              (SELECT count(*) FROM reviews WHERE user_id = $1)::int AS reviews,
              (SELECT count(*) FROM saved_treks WHERE user_id = $1)::int AS saved`,
      [req.user.id]
    );
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// GET /api/hikes -> my finished hikes (without the long path)
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT ${SUMMARY} FROM hikes h JOIN treks t ON t.id = h.trek_id WHERE h.user_id = $1 ORDER BY h.started_at DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/hikes/:id -> Trek Summary, including the recorded path
router.get('/:id', async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rows } = await pool.query(
      `SELECT ${SUMMARY}, h.path FROM hikes h JOIN treks t ON t.id = h.trek_id WHERE h.id = $1 AND h.user_id = $2`,
      [id, req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Hike not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/hikes/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rowCount } = await pool.query('DELETE FROM hikes WHERE id = $1 AND user_id = $2', [id, req.user.id]);
    if (!rowCount) return res.status(404).json({ error: 'Hike not found' });
    res.status(204).end();
  } catch (err) {
    next(err);
  }
});

export default router;
