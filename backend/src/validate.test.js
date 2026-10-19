import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validate } from './validate.js';

const spec = {
  name: ['text'],
  level: ['enum', { values: ['Easy', 'Hard'] }],
  km: ['num', { min: 0 }],
  stock: ['int', { min: 0, optional: true }],
  owner_id: ['int', { optional: true, nullable: true }],
  tags: ['list', { optional: true }],
  opens: ['time', { optional: true }],
};
const ok = { name: 'Ella', level: 'Easy', km: 9.5 };

test('a good body passes and only sent fields come back', () => {
  assert.deepEqual(validate(spec, ok), { values: ok });
  assert.deepEqual(validate(spec, { ...ok, owner_id: null, opens: '07:30', tags: ['a'] }).values.owner_id, null);
});

test('bad bodies are refused with a reason', () => {
  const bad = (body, opts) => validate(spec, body, opts).error;
  assert.match(bad({ level: 'Easy', km: 1 }), /name is required/);
  assert.match(bad({ ...ok, name: '   ' }), /name is not valid/);
  assert.match(bad({ ...ok, level: 'Extreme' }), /level is not valid/);
  assert.match(bad({ ...ok, km: -1 }), /km is not valid/);
  assert.match(bad({ ...ok, km: '5' }), /km is not valid/);          // numbers sent as text are refused
  assert.match(bad({ ...ok, stock: 1.5 }), /stock is not valid/);
  assert.match(bad({ ...ok, owner_id: 'x' }), /owner_id is not valid/);
  assert.match(bad({ ...ok, opens: '25:00' }), /opens is not valid/);
  assert.match(bad({ ...ok, tags: [1] }), /tags is not valid/);
  assert.match(bad({ ...ok, id: 5 }), /Unknown field: id/);          // can't set fields we did not list
  assert.match(bad([]), /JSON object/);
  assert.match(bad(null), /JSON object/);
});

test('updates need at least one field, but not all of them', () => {
  assert.deepEqual(validate(spec, { km: 3 }, { partial: true }), { values: { km: 3 } });
  assert.match(validate(spec, {}, { partial: true }).error, /at least one/);
  assert.match(validate(spec, { km: -3 }, { partial: true }).error, /km is not valid/);
});
