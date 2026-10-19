// npm run make-admin -- someone@example.com   ->  turns an existing account into an admin.
// This is how the very first admin is made (the API cannot, because only admins may change roles).
import pg from 'pg';

const email = process.argv[2]?.toLowerCase();
if (!email) throw new Error('Usage: npm run make-admin -- someone@example.com');
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const { rows } = await pool.query("UPDATE users SET role = 'admin' WHERE email = $1 RETURNING id, full_name, email, role", [email]);
console.log(rows.length ? `Now an admin: ${rows[0].full_name} <${rows[0].email}>` : `No account with email ${email}. Sign up in the app first.`);
await pool.end();
