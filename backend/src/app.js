import express from 'express';
import cors from 'cors';
import treks from './routes/treks.js';
import auth from './routes/auth.js';
import reviews from './routes/reviews.js';
import saved from './routes/saved.js';
import parking from './routes/parking.js';
import shops from './routes/shops.js';
import bookings from './routes/bookings.js';
import admin from './routes/admin.js';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use('/api/treks', treks);
app.use('/api/auth', auth);
app.use('/api', reviews);
app.use('/api/saved', saved);
app.use('/api', parking);
app.use('/api/shops', shops);
app.use('/api', bookings);
app.use('/api/admin', admin);

// Express recognises error handlers by their 4 arguments.
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

export default app;
