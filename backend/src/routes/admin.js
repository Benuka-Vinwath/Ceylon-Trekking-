import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireAdmin } from '../auth.js';
import { parseId } from '../util.js';
import { validate } from '../validate.js';

const router = Router();
router.use(requireAuth, requireAdmin); // every route in this file is admin-only

const lat = ['num', { min: -90, max: 90 }];
const lng = ['num', { min: -180, max: 180 }];
const name = ['text'];
const optionalText = ['text', { optional: true }];
const money = ['num', { min: 0, max: 100000 }];
const count = ['int', { min: 0, max: 100000 }];

// What an admin may send for each kind of thing. Anything not listed here is refused.
const TREK = {
  name, region: ['text'], difficulty: ['enum', { values: ['Easy', 'Moderate', 'Hard'] }],
  distance_km: ['num', { min: 0.1, max: 1000 }], duration_hrs: ['num', { min: 0.1, max: 200 }],
  elevation_m: ['int', { min: 0, max: 9000 }], description: ['text', { optional: true, max: 5000 }], lat, lng,
};
const PARKING = {
  trek_id: ['int', { min: 1 }], name, address: optionalText, lat, lng, spaces: count,
  fee_per_day: ['num', { min: 0, max: 100000, optional: true }], is_covered: ['bool', { optional: true }],
  hours: optionalText, vehicles: ['list', { optional: true }], facilities: ['list', { optional: true }],
  status: ['enum', { values: ['Open', 'Limited', 'Closed'], optional: true }],
};
const SHOP = {
  owner_id: ['int', { min: 1, optional: true, nullable: true }], name, address: optionalText, phone: optionalText, lat, lng,
  opens: ['time'], closes: ['time'], rating: ['num', { min: 0, max: 5, optional: true, nullable: true }],
};
const WAYPOINT = { trek_id: ['int', { min: 1 }], position: ['int', { min: 1, max: 1000 }], name, lat, lng, elevation_m: ['int', { min: -100, max: 9000, optional: true }] };
const OFFLINE_MAP = {
  trek_id: ['int', { min: 1 }], size_mb: ['num', { min: 0.1, max: 5000 }],
  south: lat, north: lat, west: lng, east: lng,
};
const EQUIPMENT = { shop_id: ['int', { min: 1 }], name, price_per_day: money, stock: count };

// Makes POST /path, PUT /path/:id and DELETE /path/:id for one table.
// Table and column names come from the lists above (never from the request), so they are safe to put in the SQL.
function crud(path, table, spec) {
  router.post(path, async (req, res, next) => {
    try {
      const { values, error } = validate(spec, req.body);
      if (error) return res.status(400).json({ error });
      const cols = Object.keys(values);
      const { rows } = await pool.query(
        `INSERT INTO ${table} (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING *`,
        Object.values(values)
      );
      res.status(201).json(rows[0]);
    } catch (err) {
      if (err.code === '23503') return res.status(400).json({ error: 'A linked item (trek, shop or owner) does not exist' });
      if (err.code === '23505') return res.status(409).json({ error: 'That already exists (for example the same position on a trek, or a second map for one trek)' });
      next(err);
    }
  });

  router.put(`${path}/:id`, async (req, res, next) => {
    try {
      const id = parseId(req.params.id);
      if (id === null) return res.status(400).json({ error: 'Invalid id' });
      const { values, error } = validate(spec, req.body, { partial: true }); // only the fields sent are changed
      if (error) return res.status(400).json({ error });
      const cols = Object.keys(values);
      const { rows } = await pool.query(
        `UPDATE ${table} SET ${cols.map((c, i) => `${c} = $${i + 1}`).join(', ')} WHERE id = $${cols.length + 1} RETURNING *`,
        [...Object.values(values), id]
      );
      if (!rows.length) return res.status(404).json({ error: 'Not found' });
      res.json(rows[0]);
    } catch (err) {
      if (err.code === '23503') return res.status(400).json({ error: 'A linked item (trek, shop or owner) does not exist' });
      if (err.code === '23505') return res.status(409).json({ error: 'That already exists (for example the same position on a trek, or a second map for one trek)' });
      next(err);
    }
  });

  router.delete(`${path}/:id`, async (req, res, next) => {
    try {
      const id = parseId(req.params.id);
      if (id === null) return res.status(400).json({ error: 'Invalid id' });
      const { rowCount } = await pool.query(`DELETE FROM ${table} WHERE id = $1`, [id]);
      if (!rowCount) return res.status(404).json({ error: 'Not found' });
      res.status(204).end();
    } catch (err) {
      if (err.code === '23503') return res.status(409).json({ error: 'Still in use (for example by a booking), so it cannot be deleted' });
      next(err);
    }
  });
}

crud('/treks', 'treks', TREK);
crud('/parking', 'parking_locations', PARKING);
crud('/shops', 'shops', SHOP); // setting owner_id here is how a shop gets its owner
crud('/equipment', 'equipment', EQUIPMENT);
crud('/waypoints', 'trek_waypoints', WAYPOINT);
crud('/offline-maps', 'offline_maps', OFFLINE_MAP);

// GET /api/admin/stats -> the four tiles at the top of the Admin Dashboard
router.get('/stats', async (_req, res, next) => {
  try {
    const { rows } = await pool.query(`SELECT
      (SELECT count(*) FROM treks)::int AS treks,
      (SELECT count(*) FROM shops)::int AS shops,
      (SELECT count(*) FROM parking_locations)::int AS parking,
      (SELECT count(*) FROM users)::int AS users,
      (SELECT count(*) FROM reviews)::int AS reviews,
      (SELECT count(*) FROM reviews WHERE flagged)::int AS flagged_reviews,
      (SELECT count(*) FROM bookings WHERE status = 'confirmed')::int AS active_bookings`);
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// GET /api/admin/reviews?flagged=true -> "User reviews" and the "Flagged reviews" card
router.get('/reviews', async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT r.id, r.rating, r.comment, r.tags, r.flagged, r.created_at, u.full_name, t.name AS trek_name
       FROM reviews r JOIN users u ON u.id = r.user_id JOIN treks t ON t.id = r.trek_id
       ${req.query.flagged === 'true' ? 'WHERE r.flagged' : ''} ORDER BY r.created_at DESC`
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// POST /api/admin/reviews/:id/unflag -> the "Keep" button. ("Remove" is DELETE /api/reviews/:id)
router.post('/reviews/:id/unflag', async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rowCount } = await pool.query('UPDATE reviews SET flagged = false WHERE id = $1', [id]);
    if (!rowCount) return res.status(404).json({ error: 'Review not found' });
    res.status(204).end();
  } catch (err) {
    next(err);
  }
});

// GET /api/admin/users
router.get('/users', async (_req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT id, full_name, email, role, created_at FROM users ORDER BY id');
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// PUT /api/admin/users/:id/role  body: { role }
router.put('/users/:id/role', async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    if (!['trekker', 'shop_owner', 'admin'].includes(req.body?.role)) return res.status(400).json({ error: 'role must be trekker, shop_owner or admin' });
    if (id === req.user.id) return res.status(400).json({ error: 'You cannot change your own role' }); // stops the last admin locking everyone out
    const { rows } = await pool.query('UPDATE users SET role = $1 WHERE id = $2 RETURNING id, full_name, email, role', [req.body.role, id]);
    if (!rows.length) return res.status(404).json({ error: 'User not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

export default router;
