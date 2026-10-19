import pg from 'pg';

// One pool = a few reusable DB connections shared by all requests.
export const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });

// The database sends exact decimals (prices, ratings) as text by default; the API should send them as numbers.
pg.types.setTypeParser(pg.types.builtins.NUMERIC, parseFloat);
