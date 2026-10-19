import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, isAdmin } from '../auth.js';
import { parseId } from '../util.js';

const router = Router();
const TAGS = ['Great views', 'Well marked', 'Crowded', 'Challenging', 'Family friendly']; // chips in Figma

// Checks the body of a review. Returns an error message, or null if it is fine.
function checkReview({ rating, comment = '', tags = [] }) {
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) return 'Rating must be a whole number from 1 to 5';
  if (typeof comment !== 'string' || comment.length > 1000) return 'Comment must be text up to 1000 characters';
  if (!Array.isArray(tags) || !tags.every((t) => TAGS.includes(t))) return `Tags must be from: ${TAGS.join(', ')}`;
  return null;
}

// GET /api/treks/:id/reviews -> Reviews screen (public)
router.get('/treks/:id/reviews', async (req, res, next) => {
  try {
    const trekId = parseId(req.params.id);
    if (trekId === null) return res.status(400).json({ error: 'Invalid id' });
    const { rows } = await pool.query(
      `SELECT r.id, r.rating, r.comment, r.tags, r.created_at, u.full_name
       FROM reviews r JOIN users u ON u.id = r.user_id
       WHERE r.trek_id = $1 ORDER BY r.created_at DESC`,
      [trekId]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// POST /api/treks/:id/reviews  body: { rating, comment?, tags? } -> Write Review screen (login needed)
router.post('/treks/:id/reviews', requireAuth, async (req, res, next) => {
  try {
    const trekId = parseId(req.params.id);
    if (trekId === null) return res.status(400).json({ error: 'Invalid id' });
    const problem = checkReview(req.body);
    if (problem) return res.status(400).json({ error: problem });

    const { rating, comment = '', tags = [] } = req.body;
    const { rows } = await pool.query(
      'INSERT INTO reviews (trek_id, user_id, rating, comment, tags) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [trekId, req.user.id, rating, comment, tags]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    if (err.code === '23505') return res.status(409).json({ error: 'You already reviewed this trek' });
    if (err.code === '23503') return res.status(404).json({ error: 'Trek not found' }); // foreign key: no such trek
    next(err);
  }
});

// GET /api/reviews/mine -> Profile: "My reviews" (must come before /reviews/:id)
router.get('/reviews/mine', requireAuth, async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT r.id, r.rating, r.comment, r.tags, r.created_at, t.id AS trek_id, t.name AS trek_name
       FROM reviews r JOIN treks t ON t.id = r.trek_id
       WHERE r.user_id = $1 ORDER BY r.created_at DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// PUT /api/reviews/:id  body: { rating, comment?, tags? } -> edit your own review
router.put('/reviews/:id', requireAuth, async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const problem = checkReview(req.body);
    if (problem) return res.status(400).json({ error: problem });

    const { rating, comment = '', tags = [] } = req.body;
    // "AND user_id = $5" means you can only change your own review.
    const { rows } = await pool.query(
      'UPDATE reviews SET rating = $1, comment = $2, tags = $3 WHERE id = $4 AND user_id = $5 RETURNING *',
      [rating, comment, tags, id, req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Review not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// POST /api/reviews/:id/flag -> "Report" button: any logged-in user can send a review to the admins
router.post('/reviews/:id/flag', requireAuth, async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rowCount } = await pool.query('UPDATE reviews SET flagged = true WHERE id = $1', [id]);
    if (!rowCount) return res.status(404).json({ error: 'Review not found' });
    res.status(204).end();
  } catch (err) {
    next(err);
  }
});

// DELETE /api/reviews/:id -> delete your own review (admins can delete any: Admin Dashboard)
router.delete('/reviews/:id', requireAuth, async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rowCount } = await pool.query(
      'DELETE FROM reviews WHERE id = $1 AND ($2 OR user_id = $3)',
      [id, await isAdmin(req.user.id), req.user.id]
    );
    if (!rowCount) return res.status(404).json({ error: 'Review not found' });
    res.status(204).end();
  } catch (err) {
    next(err);
  }
});

export default router;
