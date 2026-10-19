// Checks a request body against a field list.
//   spec: { field: [type, { optional, nullable, min, max, values }] }
//   types: text, int, num, bool, list (of short texts), time (HH:MM), enum (needs values)
// Returns { values } with only the fields that were sent, or { error }.
// partial = true is for updates: nothing is required, but at least one field must be sent.
const CHECKS = {
  text: (v, o) => typeof v === 'string' && v.length <= (o.max ?? 500) && (o.optional || v.trim() !== ''),
  int: (v, o) => Number.isInteger(v) && v >= (o.min ?? -Infinity) && v <= (o.max ?? Infinity),
  num: (v, o) => typeof v === 'number' && Number.isFinite(v) && v >= (o.min ?? -Infinity) && v <= (o.max ?? Infinity),
  bool: (v) => typeof v === 'boolean',
  list: (v) => Array.isArray(v) && v.length <= 20 && v.every((x) => typeof x === 'string' && x.length > 0 && x.length <= 50),
  time: (v) => typeof v === 'string' && /^([01]\d|2[0-3]):[0-5]\d$/.test(v),
  enum: (v, o) => o.values.includes(v),
};

export function validate(spec, body, { partial = false } = {}) {
  if (typeof body !== 'object' || body === null || Array.isArray(body)) return { error: 'Send a JSON object' };
  const unknown = Object.keys(body).find((k) => !(k in spec));
  if (unknown) return { error: `Unknown field: ${unknown}` };

  const values = {};
  for (const [field, [type, opts = {}]] of Object.entries(spec)) {
    const v = body[field];
    if (v === undefined) {
      if (!partial && !opts.optional) return { error: `${field} is required` };
      continue;
    }
    if (v === null && opts.nullable) values[field] = null;
    else if (CHECKS[type](v, opts)) values[field] = v;
    else return { error: `${field} is not valid` };
  }
  if (partial && !Object.keys(values).length) return { error: 'Send at least one field to change' };
  return { values };
}
