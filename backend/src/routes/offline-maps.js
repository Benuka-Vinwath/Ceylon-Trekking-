import { Router } from 'express';
import { pool } from '../db.js';
import { parseId } from '../util.js';

const router = Router();

// GET /api/offline-maps -> the Offline Maps screen: every map pack the app can download
router.get('/', async (_req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT m.id, m.trek_id, t.name AS trek_name, t.region, m.size_mb, m.south, m.west, m.north, m.east, m.updated_at
       FROM offline_maps m JOIN treks t ON t.id = m.trek_id ORDER BY t.name`
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/offline-maps/:trekId -> one pack, plus the trek's route, so Live Navigation can work offline
router.get('/:trekId', async (req, res, next) => {
  try {
    const trekId = parseId(req.params.trekId);
    if (trekId === null) return res.status(400).json({ error: 'Invalid id' });
    const map = await pool.query(
      `SELECT m.id, m.trek_id, t.name AS trek_name, m.size_mb, m.south, m.west, m.north, m.east, m.updated_at
       FROM offline_maps m JOIN treks t ON t.id = m.trek_id WHERE m.trek_id = $1`,
      [trekId]
    );
    if (!map.rows.length) return res.status(404).json({ error: 'No offline map for this trek' });
    const route = await pool.query('SELECT position, name, lat, lng, elevation_m FROM trek_waypoints WHERE trek_id = $1 ORDER BY position', [trekId]);
    res.json({ ...map.rows[0], waypoints: route.rows });
  } catch (err) {
    next(err);
  }
});

export default router;
