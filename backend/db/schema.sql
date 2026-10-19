-- Lesson 1: a table is a list of one kind of thing; a foreign key links two kinds.
CREATE TABLE users (
  id            SERIAL PRIMARY KEY,
  full_name     TEXT NOT NULL,
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'trekker' CHECK (role IN ('trekker','shop_owner','admin')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE treks (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  region       TEXT NOT NULL,                       -- Central, Uva, Southern ...
  difficulty   TEXT NOT NULL CHECK (difficulty IN ('Easy','Moderate','Hard')),
  distance_km  NUMERIC(5,1) NOT NULL,
  duration_hrs NUMERIC(4,1) NOT NULL,
  elevation_m  INTEGER NOT NULL,
  description  TEXT NOT NULL DEFAULT '',
  lat          DOUBLE PRECISION NOT NULL,
  lng          DOUBLE PRECISION NOT NULL
);

CREATE TABLE reviews (
  id         SERIAL PRIMARY KEY,
  trek_id    INTEGER NOT NULL REFERENCES treks(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating     INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment    TEXT NOT NULL DEFAULT '',
  tags       TEXT[] NOT NULL DEFAULT '{}',          -- chips on the Write Review screen
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (trek_id, user_id)                          -- one review per user per trek
);

-- Many-to-many: one user saves many treks, one trek is saved by many users.
CREATE TABLE saved_treks (
  user_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  trek_id  INTEGER NOT NULL REFERENCES treks(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, trek_id)                     -- can't save the same trek twice
);
