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

-- Lesson 4: distance in km between two GPS points (the "haversine" formula: distance over a sphere).
CREATE FUNCTION distance_km(lat1 DOUBLE PRECISION, lng1 DOUBLE PRECISION, lat2 DOUBLE PRECISION, lng2 DOUBLE PRECISION)
RETURNS DOUBLE PRECISION LANGUAGE SQL IMMUTABLE AS $$
  SELECT 2 * 6371 * asin(LEAST(1, sqrt(
    sin(radians(lat2 - lat1) / 2) ^ 2 +
    cos(radians(lat1)) * cos(radians(lat2)) * sin(radians(lng2 - lng1) / 2) ^ 2)))
$$;

-- One trek has many parking places (one-to-many: the parking row holds the trek's id).
CREATE TABLE parking_locations (
  id          SERIAL PRIMARY KEY,
  trek_id     INTEGER NOT NULL REFERENCES treks(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  address     TEXT NOT NULL DEFAULT '',
  lat         DOUBLE PRECISION NOT NULL,
  lng         DOUBLE PRECISION NOT NULL,
  spaces      INTEGER NOT NULL CHECK (spaces >= 0),
  fee_per_day NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (fee_per_day >= 0),   -- 0 means free
  is_covered  BOOLEAN NOT NULL DEFAULT false,
  hours       TEXT NOT NULL DEFAULT 'Open 24 h',
  vehicles    TEXT[] NOT NULL DEFAULT '{}',
  facilities  TEXT[] NOT NULL DEFAULT '{}',
  status      TEXT NOT NULL DEFAULT 'Open' CHECK (status IN ('Open','Limited','Closed'))
);

CREATE TABLE shops (
  id        SERIAL PRIMARY KEY,
  owner_id  INTEGER REFERENCES users(id) ON DELETE SET NULL,   -- the shop_owner account (used in lesson 6)
  name      TEXT NOT NULL,
  address   TEXT NOT NULL DEFAULT '',
  phone     TEXT NOT NULL DEFAULT '',
  lat       DOUBLE PRECISION NOT NULL,
  lng       DOUBLE PRECISION NOT NULL,
  opens     TIME NOT NULL,
  closes    TIME NOT NULL,
  rating    NUMERIC(2,1)    -- shortcut: a typed-in number, because shops have no reviews yet; replace if shop reviews are added
);

CREATE TABLE equipment (
  id            SERIAL PRIMARY KEY,
  shop_id       INTEGER NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  price_per_day NUMERIC(8,2) NOT NULL CHECK (price_per_day >= 0),
  stock         INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

-- Lesson 5: a booking is one header row plus one row per kind of equipment in it.
CREATE TABLE bookings (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  shop_id     INTEGER NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,                        -- last day of the rental (inclusive)
  status      TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed','cancelled')),
  total_price NUMERIC(10,2) NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_date >= start_date)
);

CREATE TABLE booking_items (
  booking_id    INTEGER NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  equipment_id  INTEGER NOT NULL REFERENCES equipment(id),   -- no cascade: deleting gear must not rewrite past bookings
  quantity      INTEGER NOT NULL CHECK (quantity > 0),
  price_per_day NUMERIC(8,2) NOT NULL,              -- copied at booking time, so later price changes don't alter old bookings
  PRIMARY KEY (booking_id, equipment_id)
);
