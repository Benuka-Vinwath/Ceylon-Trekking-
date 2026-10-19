import express from 'express';
import cors from 'cors';
import { pool } from './db.js';
import treks from './routes/treks.js';
import auth from './routes/auth.js';
import reviews from './routes/reviews.js';
import saved from './routes/saved.js';
import parking from './routes/parking.js';
import shops from './routes/shops.js';
import bookings from './routes/bookings.js';
import admin from './routes/admin.js';
import hikes from './routes/hikes.js';
import offlineMaps from './routes/offline-maps.js';

const app = express();
app.disable('x-powered-by'); // don't announce which framework we use
if (process.env.TRUST_PROXY) app.set('trust proxy', Number(process.env.TRUST_PROXY)); // set to 1 behind a hosting proxy, so rate limits see the real client address
app.use(cors());
app.use(express.json({ limit: '500kb' })); // room for a recorded hike path, but nothing huge

app.get('/health', (_req, res) => res.json({ ok: true })); // "is the server up?"
app.get('/health/db', async (_req, res) => { // "can it reach the database?"
  try {
    await pool.query('SELECT 1');
    res.json({ ok: true });
  } catch {
    res.status(503).json({ ok: false });
  }
});

app.use('/api/treks', treks);
app.use('/api/auth', auth);
app.use('/api', reviews);
app.use('/api/saved', saved);
app.use('/api', parking);
app.use('/api/shops', shops);
app.use('/api', bookings);
app.use('/api/admin', admin);
app.use('/api/hikes', hikes);
app.use('/api/offline-maps', offlineMaps);

// Unknown address: answer in JSON like everything else, not with an HTML page.
app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

// Express recognises error handlers by their 4 arguments.
app.use((err, _req, res, _next) => {
  if (err.type === 'entity.parse.failed') return res.status(400).json({ error: 'Body is not valid JSON' });
  if (err.type === 'entity.too.large') return res.status(413).json({ error: 'Request is too large' });
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

export default app;
