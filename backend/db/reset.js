// npm run db:reset  ->  wipes the database and rebuilds it from schema.sql + seed.sql (development only).
import { readFileSync } from 'node:fs';
import pg from 'pg';

if (process.env.NODE_ENV === 'production') throw new Error('Refusing to reset a production database');
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
await pool.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
for (const file of ['schema.sql', 'seed.sql']) await pool.query(readFileSync(new URL(file, import.meta.url), 'utf8'));
console.log('Database reset: tables rebuilt and sample data loaded.');
await pool.end();
