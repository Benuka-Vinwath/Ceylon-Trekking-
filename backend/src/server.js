import app from './app.js';
import { pool } from './db.js';

// Stop at once with a clear message, instead of failing later on the first request.
const problems = [];
if (!process.env.DATABASE_URL) problems.push('DATABASE_URL is missing');
if ((process.env.JWT_SECRET || '').length < 16) problems.push('JWT_SECRET is missing or shorter than 16 characters');
if (process.env.NODE_ENV === 'production' && process.env.JWT_SECRET?.startsWith('change-me')) problems.push('JWT_SECRET is still the example value');
if (problems.length) {
  console.error(`Cannot start: ${problems.join('; ')}. See .env.example.`);
  process.exit(1);
}

const port = process.env.PORT || 3000;
const server = app.listen(port, () => console.log(`API on http://localhost:${port}`));

// Hosting platforms send SIGTERM when they stop or redeploy: finish current requests, close the database, then exit.
process.on('SIGTERM', () => server.close(() => pool.end().then(() => process.exit(0))));
