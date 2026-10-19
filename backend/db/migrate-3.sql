-- For databases created before lesson 3 (fresh installs get this from schema.sql).
ALTER TABLE reviews ADD COLUMN IF NOT EXISTS tags TEXT[] NOT NULL DEFAULT '{}';
CREATE TABLE IF NOT EXISTS saved_treks (
  user_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  trek_id  INTEGER NOT NULL REFERENCES treks(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, trek_id)
);
