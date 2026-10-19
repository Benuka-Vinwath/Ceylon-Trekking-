import { test } from 'node:test';
import assert from 'node:assert/strict';
import app from './app.js';

// Starts the real app on a random port and calls it like the Flutter app would.
async function get(path) {
  const server = app.listen(0);
  try {
    const res = await fetch(`http://localhost:${server.address().port}${path}`);
    return { status: res.status, body: await res.json() };
  } finally {
    server.close();
  }
}

test('health check', async () => {
  assert.deepEqual((await get('/health')).body, { ok: true });
});

test('bad input is rejected before touching the database', async () => {
  assert.equal((await get('/api/treks?difficulty=Nope')).status, 400);
  assert.equal((await get('/api/treks/abc')).status, 400);
});

async function post(path, body) {
  const server = app.listen(0);
  try {
    const res = await fetch(`http://localhost:${server.address().port}${path}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
    });
    return res.status;
  } finally {
    server.close();
  }
}

test('signup rejects bad input before touching the database', async () => {
  assert.equal(await post('/api/auth/signup', { full_name: 'A', email: 'nope', password: 'longenough' }), 400);
  assert.equal(await post('/api/auth/signup', { full_name: 'A', email: 'a@b.co', password: 'short' }), 400);
  assert.equal(await post('/api/auth/signup', { full_name: 'A', email: 'a@b.co', password: 'longenough', role: 'admin' }), 400);
});

test('protected route needs a token', async () => {
  assert.equal((await get('/api/auth/me')).status, 401);
});

test('reviews and saved treks need a login', async () => {
  assert.equal((await get('/api/saved')).status, 401);
  assert.equal((await get('/api/reviews/mine')).status, 401);
  assert.equal(await post('/api/treks/1/reviews', { rating: 5 }), 401);
});

test('review with a bad rating or tag is rejected before the database', async () => {
  process.env.JWT_SECRET = 'test-secret';
  const { signToken } = await import('./auth.js');
  const token = signToken({ id: 1, role: 'trekker' });
  const send = async (body) => {
    const server = app.listen(0);
    try {
      const res = await fetch(`http://localhost:${server.address().port}/api/treks/1/reviews`, {
        method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }, body: JSON.stringify(body),
      });
      return res.status;
    } finally {
      server.close();
    }
  };
  assert.equal(await send({ rating: 9 }), 400);
  assert.equal(await send({ rating: 4, tags: ['Scary'] }), 400);
});

test('parking and shops reject bad input before the database', async () => {
  for (const path of [
    '/api/parking?lat=abc&lng=81', '/api/parking?lat=6.8', '/api/parking?lat=99&lng=81', '/api/parking?fee=cheap',
    '/api/parking/abc', '/api/treks/abc/parking', '/api/shops?lat=0&lng=500', '/api/shops/abc',
  ]) {
    assert.equal((await get(path)).status, 400, path);
  }
});

test('bookings need a login, and bad bookings are rejected before the database', async () => {
  assert.equal(await post('/api/bookings', {}), 401);
  assert.equal((await get('/api/bookings')).status, 401);

  process.env.JWT_SECRET = 'test-secret';
  const { signToken } = await import('./auth.js');
  const token = signToken({ id: 1, role: 'trekker' });
  const book = async (body) => {
    const server = app.listen(0);
    try {
      const res = await fetch(`http://localhost:${server.address().port}/api/bookings`, {
        method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }, body: JSON.stringify(body),
      });
      return res.status;
    } finally {
      server.close();
    }
  };
  const ok = { shop_id: 1, start_date: '2099-01-01', end_date: '2099-01-03', items: [{ equipment_id: 1, quantity: 1 }] };
  assert.equal(await book({ ...ok, shop_id: 'x' }), 400);
  assert.equal(await book({ ...ok, start_date: '2020-01-01' }), 400);          // past
  assert.equal(await book({ ...ok, start_date: '2099-02-31' }), 400);          // not a real date
  assert.equal(await book({ ...ok, end_date: '2098-12-31' }), 400);            // ends before it starts
  assert.equal(await book({ ...ok, end_date: '2099-03-01' }), 400);            // over 30 days
  assert.equal(await book({ ...ok, items: [] }), 400);
  assert.equal(await book({ ...ok, items: [{ equipment_id: 1, quantity: 0 }] }), 400);
  assert.equal(await book({ ...ok, items: [{ equipment_id: 1, quantity: 1 }, { equipment_id: 1, quantity: 1 }] }), 400);
});

test('availability needs valid dates', async () => {
  assert.equal((await get('/api/shops/1/availability')).status, 400);
  assert.equal((await get('/api/shops/abc/availability?start=2099-01-01&end=2099-01-02')).status, 400);
});

test('admin routes refuse people who are not logged in', async () => {
  for (const path of ['/api/admin/stats', '/api/admin/users', '/api/admin/reviews']) {
    assert.equal((await get(path)).status, 401, path);
  }
  assert.equal(await post('/api/admin/treks', { name: 'x' }), 401);
  assert.equal(await post('/api/reviews/1/flag', {}), 401);
});

test('unknown addresses and broken JSON get clean JSON answers', async () => {
  const notFound = await get('/api/nothing-here');
  assert.deepEqual([notFound.status, notFound.body], [404, { error: 'Not found' }]);
  const server = app.listen(0);
  try {
    const base = `http://localhost:${server.address().port}`;
    const bad = await fetch(`${base}/api/auth/login`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{not json' });
    assert.equal(bad.status, 400);
    const big = await fetch(`${base}/api/auth/login`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ x: 'a'.repeat(600_000) }) });
    assert.equal(big.status, 413);
  } finally {
    server.close();
  }
});

test('hikes, offline maps and profile stats: login and input checks', async () => {
  assert.equal((await get('/api/hikes')).status, 401);
  assert.equal((await get('/api/hikes/stats')).status, 401);
  assert.equal((await get('/api/offline-maps/abc')).status, 400);
  assert.equal((await get('/api/treks/abc/route')).status, 400);

  process.env.JWT_SECRET = 'test-secret';
  const { signToken } = await import('./auth.js');
  const token = signToken({ id: 1, role: 'trekker' });
  const send = async (body) => {
    const server = app.listen(0);
    try {
      const res = await fetch(`http://localhost:${server.address().port}/api/hikes`, {
        method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }, body: JSON.stringify(body),
      });
      return res.status;
    } finally {
      server.close();
    }
  };
  const ok = { trek_id: 1, distance_km: 11, duration_seconds: 18760, started_at: '2026-01-01T08:00:00Z' };
  assert.equal(await send({ ...ok, distance_km: 0 }), 400);
  assert.equal(await send({ ...ok, duration_seconds: -5 }), 400);
  assert.equal(await send({ ...ok, started_at: 'yesterday' }), 400);
  assert.equal(await send({ ...ok, started_at: '2999-01-01T00:00:00Z' }), 400);   // in the future
  assert.equal(await send({ ...ok, path: [[6.8, 80.5], [99, 80.5]] }), 400);      // latitude 99
  assert.equal(await send({ ...ok, path: 'not a list' }), 400);
  assert.equal(await send({ ...ok, extra: 1 }), 400);
});

test('too many login or signup attempts get "429 Too Many Requests"', async () => {
  const statuses = [];
  for (let i = 0; i < 25; i++) statuses.push(await post('/api/auth/signup', { full_name: '', email: 'bad', password: 'x' }));
  assert.equal(statuses[0], 400);
  assert.ok(statuses.includes(429), 'expected a 429 after many attempts');
});
