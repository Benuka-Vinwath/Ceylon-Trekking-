import { Router } from 'express';
import { pool } from '../db.js';
import { parseId, parseLocation } from '../util.js';

const router = Router();

// "Open" is worked out from the opening hours and the current time in Sri Lanka.
const IS_OPEN = `((now() AT TIME ZONE 'Asia/Colombo')::time BETWEEN s.opens AND s.closes)`;
const COLS = `s.id, s.name, s.address, s.phone, s.lat, s.lng, s.opens, s.closes, s.rating::float AS rating, ${IS_OPEN} AS is_open`;

// GET /api/shops?lat=6.87&lng=81.04&q=ella -> Gear Shops screen (nearest first if lat/lng given)
router.get('/', async (req, res, next) => {
  try {
    const { lat, lng, error } = parseLocation(req.query);
    if (error) return res.status(400).json({ error });
    const params = [];
    const where = [];
    let distance = 'NULL::float';
    let order = 's.name';
    if (lat !== undefined) {
      params.push(lat, lng);
      distance = 'ROUND(distance_km(s.lat, s.lng, $1, $2)::numeric, 1)::float';
      order = 'distance_km(s.lat, s.lng, $1, $2)';
    }
    if (req.query.q) {
      params.push(`%${req.query.q}%`);
      where.push(`s.name ILIKE $${params.length}`);
    }
    // array_agg collects each shop's equipment names into one list; FILTER skips shops with no equipment.
    const { rows } = await pool.query(
      `SELECT ${COLS}, ${distance} AS distance_km,
         COALESCE(array_agg(e.name ORDER BY e.name) FILTER (WHERE e.id IS NOT NULL), '{}') AS equipment_names
       FROM shops s LEFT JOIN equipment e ON e.shop_id = s.id
       ${where.length ? 'WHERE ' + where.join(' AND ') : ''} GROUP BY s.id ORDER BY ${order}`,
      params
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/shops/:id -> Shop Detail, with its equipment list
router.get('/:id', async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const shop = await pool.query(`SELECT ${COLS} FROM shops s WHERE s.id = $1`, [id]);
    if (!shop.rows.length) return res.status(404).json({ error: 'Shop not found' });
    const equipment = await pool.query(
      'SELECT id, name, price_per_day::float AS price_per_day, stock, stock > 0 AS in_stock FROM equipment WHERE shop_id = $1 ORDER BY id',
      [id]
    );
    res.json({ ...shop.rows[0], equipment: equipment.rows });
  } catch (err) {
    next(err);
  }
});

export default router;
