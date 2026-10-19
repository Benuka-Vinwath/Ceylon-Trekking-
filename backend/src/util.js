// Turns a URL piece like "5" into 5. Returns null for "abc", "1.5", etc.
export const parseId = (value) => (Number.isInteger(Number(value)) ? Number(value) : null);
