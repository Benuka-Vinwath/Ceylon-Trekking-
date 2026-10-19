import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth } from '../auth.js';
import { parseId } from '../util.js';

const router = Router();
router.use(requireAuth); // every route in this file needs a login

// GET /api/saved -> Saved Treks screen
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT t.* FROM saved_treks s JOIN treks t ON t.id = s.trek_id
       WHERE s.user_id = $1 ORDER BY s.saved_at DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// PUT /api/saved/:trekId -> heart button on. Safe to repeat.
router.put('/:trekId', async (req, res, next) => {
  try {
    const trekId = parseId(req.params.trekId);
    if (trekId === null) return res.status(400).json({ error: 'Invalid id' });
    await pool.query('INSERT INTO saved_treks (user_id, trek_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [req.user.id, trekId]);
    res.status(204).end();
  } catch (err) {
    if (err.code === '23503') return res.status(404).json({ error: 'Trek not found' });
    next(err);
  }
});

// DELETE /api/saved/:trekId -> heart button off. Safe to repeat.
router.delete('/:trekId', async (req, res, next) => {
  try {
    const trekId = parseId(req.params.trekId);
    if (trekId === null) return res.status(400).json({ error: 'Invalid id' });
    await pool.query('DELETE FROM saved_treks WHERE user_id = $1 AND trek_id = $2', [req.user.id, trekId]);
    res.status(204).end();
  } catch (err) {
    next(err);
  }
});

export default router;
