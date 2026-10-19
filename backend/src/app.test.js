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
