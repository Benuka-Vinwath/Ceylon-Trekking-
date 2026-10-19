import express from 'express';
import cors from 'cors';
import treks from './routes/treks.js';
import auth from './routes/auth.js';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use('/api/treks', treks);
app.use('/api/auth', auth);

// Express recognises error handlers by their 4 arguments.
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

export default app;
