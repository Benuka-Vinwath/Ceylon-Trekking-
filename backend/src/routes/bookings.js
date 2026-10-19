import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth } from '../auth.js';
import { parseId } from '../util.js';

const router = Router();
const MAX_DAYS = 30;
const MAX_ITEMS = 20;

const today = () => new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Colombo' }); // "YYYY-MM-DD"
const dayCount = (start, end) => (Date.parse(end) - Date.parse(start)) / 864e5 + 1; // both ends included

function isDate(s) {
  if (typeof s !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(s)) return false;
  const d = new Date(`${s}T00:00:00Z`);
  return !isNaN(d) && d.toISOString().slice(0, 10) === s; // rejects 2026-02-31
}

// Returns an error message for a bad date range, or null.
function checkRange(start, end) {
  if (!isDate(start) || !isDate(end)) return 'Dates must look like 2026-11-30';
  if (start < today()) return 'Start date cannot be in the past'; // text dates in this format sort correctly
  if (end < start) return 'End date cannot be before start date';
  if (dayCount(start, end) > MAX_DAYS) return `Rentals are limited to ${MAX_DAYS} days`;
  return null;
}

// Most units of one piece of gear that are booked on any single day of the range.
// Counting day by day matters: two bookings on different days never block each other.
const peakBooked = (equipmentId) => `
  SELECT COALESCE(MAX(per_day.booked), 0)::int AS peak FROM (
    SELECT SUM(bi.quantity) AS booked
    FROM generate_series($2::date, $3::date, '1 day') AS day
    JOIN bookings b ON b.status = 'confirmed' AND b.start_date <= day::date AND b.end_date >= day::date
    JOIN booking_items bi ON bi.booking_id = b.id AND bi.equipment_id = ${equipmentId}
    GROUP BY day) per_day`;

// A refusal we want to send to the app (as opposed to a crash).
class Refuse extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

const BOOKING = `SELECT b.id, b.user_id, b.shop_id, s.owner_id, s.name AS shop_name, u.full_name AS customer_name,
    b.start_date::text AS start_date, b.end_date::text AS end_date, b.status, b.total_price::float AS total_price, b.created_at,
    (SELECT json_agg(json_build_object('equipment_id', e.id, 'name', e.name, 'quantity', bi.quantity, 'price_per_day', bi.price_per_day::float) ORDER BY e.id)
       FROM booking_items bi JOIN equipment e ON e.id = bi.equipment_id WHERE bi.booking_id = b.id) AS items
  FROM bookings b JOIN shops s ON s.id = b.shop_id JOIN users u ON u.id = b.user_id`;

// Removes the internal ids before a booking is sent to the app.
const publicBooking = ({ user_id, owner_id, ...booking }) => booking;

// GET /api/shops/:id/availability?start=2026-11-01&end=2026-11-03 -> how many of each item are free for those days
router.get('/shops/:id/availability', async (req, res, next) => {
  try {
    const shopId = parseId(req.params.id);
    if (shopId === null) return res.status(400).json({ error: 'Invalid id' });
    const problem = checkRange(req.query.start, req.query.end);
    if (problem) return res.status(400).json({ error: problem });
    const shop = await pool.query('SELECT 1 FROM shops WHERE id = $1', [shopId]);
    if (!shop.rows.length) return res.status(404).json({ error: 'Shop not found' });

    // LATERAL lets the inner query use each equipment row (e.id) from the outer query.
    const { rows } = await pool.query(
      `SELECT e.id, e.name, e.price_per_day::float AS price_per_day, e.stock, GREATEST(e.stock - p.peak, 0) AS available
       FROM equipment e CROSS JOIN LATERAL (${peakBooked('e.id')}) p
       WHERE e.shop_id = $1 ORDER BY e.id`,
      [shopId, req.query.start, req.query.end]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// POST /api/bookings  body: { shop_id, start_date, end_date, items: [{ equipment_id, quantity }] }
router.post('/bookings', requireAuth, async (req, res, next) => {
  const { shop_id, start_date, end_date, items } = req.body;
  if (!Number.isInteger(shop_id)) return res.status(400).json({ error: 'shop_id is required' });
  const problem = checkRange(start_date, end_date);
  if (problem) return res.status(400).json({ error: problem });
  if (!Array.isArray(items) || !items.length || items.length > MAX_ITEMS) return res.status(400).json({ error: `Choose 1 to ${MAX_ITEMS} items` });
  if (!items.every((i) => Number.isInteger(i?.equipment_id) && Number.isInteger(i?.quantity) && i.quantity >= 1 && i.quantity <= 50)) {
    return res.status(400).json({ error: 'Each item needs a whole equipment_id and a quantity from 1 to 50' });
  }
  const ids = items.map((i) => i.equipment_id);
  if (new Set(ids).size !== ids.length) return res.status(400).json({ error: 'Each item can only appear once' });

  const client = await pool.connect(); // one connection for the whole transaction
  try {
    await client.query('BEGIN');
    // Lock these gear rows until COMMIT. A second booking for the same gear waits here, so it sees our booking.
    // ORDER BY id = everyone locks in the same order, which prevents two bookings waiting on each other forever.
    const { rows: gear } = await client.query(
      'SELECT id, name, price_per_day::float AS price, stock FROM equipment WHERE shop_id = $1 AND id = ANY($2) ORDER BY id FOR UPDATE',
      [shop_id, ids]
    );
    if (gear.length !== ids.length) throw new Refuse(404, 'Some equipment was not found in this shop');

    let perDay = 0;
    for (const item of items) {
      const g = gear.find((x) => x.id === item.equipment_id);
      const { rows } = await client.query(peakBooked('$1'), [g.id, start_date, end_date]);
      const free = g.stock - rows[0].peak;
      if (item.quantity > free) throw new Refuse(409, `Only ${Math.max(free, 0)} x ${g.name} available for those dates`);
      perDay += g.price * item.quantity; // the price comes from the database, never from the app
    }
    const total = Math.round(perDay * dayCount(start_date, end_date) * 100) / 100;

    const { rows } = await client.query(
      'INSERT INTO bookings (user_id, shop_id, start_date, end_date, total_price) VALUES ($1, $2, $3, $4, $5) RETURNING id',
      [req.user.id, shop_id, start_date, end_date, total]
    );
    for (const item of items) {
      const g = gear.find((x) => x.id === item.equipment_id);
      await client.query('INSERT INTO booking_items (booking_id, equipment_id, quantity, price_per_day) VALUES ($1, $2, $3, $4)', [rows[0].id, g.id, item.quantity, g.price]);
    }
    await client.query('COMMIT');

    const saved = await pool.query(`${BOOKING} WHERE b.id = $1`, [rows[0].id]);
    res.status(201).json(publicBooking(saved.rows[0]));
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {}); // undo everything: no half-made booking is ever left behind
    if (err instanceof Refuse) return res.status(err.status).json({ error: err.message });
    next(err);
  } finally {
    client.release();
  }
});

// GET /api/bookings -> my bookings
router.get('/bookings', requireAuth, async (req, res, next) => {
  try {
    const { rows } = await pool.query(`${BOOKING} WHERE b.user_id = $1 ORDER BY b.created_at DESC`, [req.user.id]);
    res.json(rows.map(publicBooking));
  } catch (err) {
    next(err);
  }
});

// GET /api/bookings/:id -> the customer, the shop's owner, or an admin
router.get('/bookings/:id', requireAuth, async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rows } = await pool.query(`${BOOKING} WHERE b.id = $1`, [id]);
    const b = rows[0];
    const allowed = b && (b.user_id === req.user.id || b.owner_id === req.user.id || req.user.role === 'admin');
    if (!allowed) return res.status(404).json({ error: 'Booking not found' }); // same answer whether it exists or not
    res.json(publicBooking(b));
  } catch (err) {
    next(err);
  }
});

// POST /api/bookings/:id/cancel -> only your own, only until the day before it starts
router.post('/bookings/:id/cancel', requireAuth, async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rowCount } = await pool.query(
      "UPDATE bookings SET status = 'cancelled' WHERE id = $1 AND user_id = $2 AND status = 'confirmed' AND start_date > $3",
      [id, req.user.id, today()]
    );
    if (!rowCount) return res.status(404).json({ error: 'Booking not found, already cancelled, or too late to cancel' });
    const { rows } = await pool.query(`${BOOKING} WHERE b.id = $1`, [id]);
    res.json(publicBooking(rows[0]));
  } catch (err) {
    next(err);
  }
});

// GET /api/shops/:id/bookings -> the shop owner's list of bookings (or an admin)
router.get('/shops/:id/bookings', requireAuth, async (req, res, next) => {
  try {
    const shopId = parseId(req.params.id);
    if (shopId === null) return res.status(400).json({ error: 'Invalid id' });
    const shop = await pool.query('SELECT owner_id FROM shops WHERE id = $1', [shopId]);
    if (!shop.rows.length) return res.status(404).json({ error: 'Shop not found' });
    if (shop.rows[0].owner_id !== req.user.id && req.user.role !== 'admin') return res.status(403).json({ error: 'Not your shop' });
    const { rows } = await pool.query(`${BOOKING} WHERE b.shop_id = $1 ORDER BY b.start_date`, [shopId]);
    res.json(rows.map(publicBooking));
  } catch (err) {
    next(err);
  }
});

export default router;
