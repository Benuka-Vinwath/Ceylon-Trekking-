// Turns a URL piece like "5" into 5. Returns null for "abc", "1.5", etc.
export const parseId = (value) => (Number.isInteger(Number(value)) ? Number(value) : null);

// Reads ?lat=..&lng=.. from the URL. Returns {} if absent, { lat, lng } if valid, { error } if not.
export function parseLocation({ lat, lng }) {
  if (lat === undefined && lng === undefined) return {};
  const la = Number(lat), ln = Number(lng);
  if (lat === '' || lng === '' || !Number.isFinite(la) || !Number.isFinite(ln) || Math.abs(la) > 90 || Math.abs(ln) > 180) {
    return { error: 'lat and lng must both be valid GPS numbers' };
  }
  return { lat: la, lng: ln };
}
