import { Router } from 'express';
import { pool } from '../db.js';
import { parseId, parseLocation } from '../util.js';

const router = Router();

// ::float turns the database's exact decimal into a normal JSON number.
const COLS = `p.id, p.trek_id, p.name, p.address, p.lat, p.lng, p.spaces, p.fee_per_day::float AS fee_per_day,
  p.is_covered, p.hours, p.vehicles, p.facilities, p.status`;

// Adds the Free / Paid / Covered chips (?fee=free|paid, ?covered=true) to the WHERE list. Returns an error text or null.
function addFilters({ fee, covered }, where) {
  if (fee === 'free') where.push('p.fee_per_day = 0');
  else if (fee === 'paid') where.push('p.fee_per_day > 0');
  else if (fee !== undefined) return 'fee must be free or paid';
  if (covered === 'true') where.push('p.is_covered');
  return null;
}

// GET /api/treks/:id/parking?fee=free&covered=true -> Parking Finder (distance from the trailhead)
router.get('/treks/:id/parking', async (req, res, next) => {
  try {
    const trekId = parseId(req.params.id);
    if (trekId === null) return res.status(400).json({ error: 'Invalid id' });
    const where = ['p.trek_id = $1'];
    const problem = addFilters(req.query, where);
    if (problem) return res.status(400).json({ error: problem });

    const { rows } = await pool.query(
      `SELECT ${COLS}, ROUND(distance_km(p.lat, p.lng, t.lat, t.lng) * 1000)::int AS distance_m
       FROM parking_locations p JOIN treks t ON t.id = p.trek_id
       WHERE ${where.join(' AND ')} ORDER BY distance_m`,
      [trekId]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/parking?lat=6.87&lng=81.04&radius_km=5&fee=free -> Map "Parking" chip: nearest first
router.get('/parking', async (req, res, next) => {
  try {
    const { lat, lng, error } = parseLocation(req.query);
    if (error) return res.status(400).json({ error });
    const where = [];
    const params = [];
    const problem = addFilters(req.query, where);
    if (problem) return res.status(400).json({ error: problem });

    let distance = 'NULL::float';
    let order = 'p.name';
    if (lat !== undefined) {
      params.push(lat, lng);
      const km = 'distance_km(p.lat, p.lng, $1, $2)';
      distance = `ROUND(${km}::numeric, 1)::float`;
      order = km;
      if (req.query.radius_km !== undefined) {
        const radius = Number(req.query.radius_km);
        if (!(radius > 0)) return res.status(400).json({ error: 'radius_km must be a positive number' });
        params.push(radius);
        where.push(`${km} <= $3`);
      }
    }
    const { rows } = await pool.query(
      `SELECT ${COLS}, t.name AS trek_name, ${distance} AS distance_km
       FROM parking_locations p JOIN treks t ON t.id = p.trek_id
       ${where.length ? 'WHERE ' + where.join(' AND ') : ''} ORDER BY ${order}`,
      params
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/parking/:id -> Parking Detail
router.get('/parking/:id', async (req, res, next) => {
  try {
    const id = parseId(req.params.id);
    if (id === null) return res.status(400).json({ error: 'Invalid id' });
    const { rows } = await pool.query(
      `SELECT ${COLS}, t.name AS trek_name FROM parking_locations p JOIN treks t ON t.id = p.trek_id WHERE p.id = $1`,
      [id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Parking not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

export default router;
