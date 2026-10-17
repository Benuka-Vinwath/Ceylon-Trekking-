import pg from 'pg';

// One pool = a few reusable DB connections shared by all requests.
export const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
