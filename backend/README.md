# Ceylon Trekking: backend API

Node.js + Express + PostgreSQL. The Flutter app talks to it with JSON over HTTP. New to the backend? Read [LEARN.md](LEARN.md).

## Run it locally
1. A PostgreSQL database named `ceylon_trekking` (install PostgreSQL, or `docker compose up -d db`).
2. `npm install`
3. Copy `.env.example` to `.env` and fill in `DATABASE_URL` and `JWT_SECRET` (the file explains how).
4. First time only: build the tables and sample data with `npm run db:reset` (this **wipes** the database, so development only).
5. `npm run dev`, then open http://localhost:3000/api/treks
6. `npm test` runs the automated tests (they don't need the database).

Make the first admin: sign up in the app, then `npm run make-admin -- your@email.com`.

## How the app talks to the API
- Base address: `http://<server>:3000`. From the Android emulator, "localhost" is `http://10.0.2.2:3000`.
- Send and receive JSON. For POST/PUT send the header `Content-Type: application/json`.
- **Logged-in routes** need the header `Authorization: Bearer <token>`. The token comes from login or signup and lasts 7 days.
- Errors always look like `{ "error": "message you can show the user" }`.
  `400` bad input, `401` not logged in, `403` not allowed, `404` not found, `409` conflict (duplicate, sold out), `413` too large, `429` too many attempts, `500` server problem.
- Dates are `YYYY-MM-DD`; times of day are `HH:MM`; timestamps are ISO text.

## Endpoints
🔒 = needs login. 👑 = admins only.

### Account (screens: Sign Up, Login, Profile)
| Method and path | Body or query | Returns |
|---|---|---|
| `POST /api/auth/signup` | `{ full_name, email, password (8+), role?: "trekker"\|"shop_owner" }` | `{ token, user }` |
| `POST /api/auth/login` | `{ email, password }` | `{ token, user }` |
| `GET /api/auth/me` 🔒 | | `{ id, full_name, email, role }` |
| `GET /api/hikes/stats` 🔒 | | `{ treks, distance_km, reviews, saved }` (Profile numbers) |

### Treks (Home, Search, Trek Details)
| Method and path | Notes |
|---|---|
| `GET /api/treks` | Optional `difficulty` (Easy/Moderate/Hard), `region`, `q` (name search), `sort=top_rated`. Each trek has `avg_rating` (null if none) and `review_count` |
| `GET /api/treks/:id` | One trek |
| `GET /api/treks/:id/route` | Waypoints in walking order, for Live Navigation (may be empty) |
| `GET /api/treks/:id/parking` | Optional `fee=free\|paid`, `covered=true`. Each has `distance_m` from the trailhead |

### Reviews (Reviews, Write Review, My reviews)
| Method and path | Notes |
|---|---|
| `GET /api/treks/:id/reviews` | Newest first, with `full_name` |
| `POST /api/treks/:id/reviews` 🔒 | `{ rating 1-5, comment?, tags?: ["Great views","Well marked","Crowded","Challenging","Family friendly"] }`. One review per user per trek (409) |
| `GET /api/reviews/mine` 🔒 | |
| `PUT /api/reviews/:id` 🔒 | Same body as POST; own reviews only |
| `DELETE /api/reviews/:id` 🔒 | Own review (admins: any) |
| `POST /api/reviews/:id/flag` 🔒 | "Report" button |

### Saved treks
`GET /api/saved` 🔒, `PUT /api/saved/:trekId` 🔒 (heart on), `DELETE /api/saved/:trekId` 🔒 (heart off). PUT and DELETE are safe to repeat.

### Map, parking and gear shops
| Method and path | Notes |
|---|---|
| `GET /api/parking` | Optional `lat`+`lng` (user's GPS, nearest first, adds `distance_km`), `radius_km`, `fee`, `covered` |
| `GET /api/parking/:id` | Parking Detail |
| `GET /api/shops` | Optional `lat`+`lng`, `q`. Each has `is_open`, `rating`, `equipment_names` |
| `GET /api/shops/:id` | Shop with `equipment: [{ id, name, price_per_day, stock, in_stock }]` |

### Booking equipment
| Method and path | Notes |
|---|---|
| `GET /api/shops/:id/availability?start=&end=` | How many of each item are free for those days (`available`) |
| `POST /api/bookings` 🔒 | `{ shop_id, start_date, end_date, items: [{ equipment_id, quantity }] }`. Max 30 days, start not in the past. `409` with a readable message if not enough stock. The server works out the price |
| `GET /api/bookings` 🔒 | My bookings |
| `GET /api/bookings/:id` 🔒 | The customer, that shop's owner, or an admin |
| `POST /api/bookings/:id/cancel` 🔒 | Own booking, until the day before it starts |
| `GET /api/shops/:id/bookings` 🔒 | The shop's owner (or an admin) |

### Hikes and offline maps (Live Navigation, Trek Summary, Offline Maps)
| Method and path | Notes |
|---|---|
| `POST /api/hikes` 🔒 | On "Finish": `{ trek_id, distance_km, duration_seconds, elevation_gain_m?, started_at, path?: [[lat,lng],...] }` (path up to 5000 points). Returns the summary incl. `avg_pace_min_per_km` |
| `GET /api/hikes` 🔒 | My hikes, newest first |
| `GET /api/hikes/:id` 🔒 | One hike including its `path` |
| `DELETE /api/hikes/:id` 🔒 | |
| `GET /api/offline-maps` | Every downloadable pack: `size_mb`, bounds (`south, west, north, east`), `updated_at` |
| `GET /api/offline-maps/:trekId` | One pack plus the trek's waypoints. **The app downloads the map tiles itself** for those bounds; the server only describes the pack |

### Admin 👑 (Admin Dashboard)
| Method and path | Notes |
|---|---|
| `GET /api/admin/stats` | `{ treks, shops, parking, users, reviews, flagged_reviews, active_bookings }` |
| `POST /api/admin/{treks,parking,shops,equipment,waypoints,offline-maps}` | Create. Field names match the database columns; wrong or unknown fields get a 400 that says which |
| `PUT /api/admin/{...}/:id` | Change only the fields sent |
| `DELETE /api/admin/{...}/:id` | `409` if still in use (for example a shop with bookings) |
| `GET /api/admin/reviews?flagged=true` | Moderation list |
| `POST /api/admin/reviews/:id/unflag` | "Keep"; "Remove" is `DELETE /api/reviews/:id` |
| `GET /api/admin/users`, `PUT /api/admin/users/:id/role` | `{ role: "trekker"\|"shop_owner"\|"admin" }`; you can't change your own |

### Health
`GET /health` (server is up), `GET /health/db` (database reachable; 503 if not).

## Deploying
Needs a hosted PostgreSQL and somewhere to run Node. The steps below are the usual pattern (for example Render or Railway); the websites change, so follow their current screens.

1. Push the repo to GitHub.
2. Create a **PostgreSQL** database on the host. Copy its connection URL.
3. Load the tables once, from your own computer: `psql "<that URL>" -f db/schema.sql`.
   **Do not load `db/seed.sql` for a real launch.** It contains made-up sample treks, phone numbers and map coordinates. Add real content through the admin routes.
4. Create a **Web Service** from the repo with root directory `backend`, build command `npm ci`, start command `node src/server.js`.
5. Set these environment variables on the service:
   - `DATABASE_URL`: the URL from step 2
   - `JWT_SECRET`: a new long random text (not the example one; the server refuses to start with it in production)
   - `NODE_ENV=production`
   - `TRUST_PROXY=1`
6. Open `https://<your-service>/health/db`. It should say `{"ok":true}`.
7. Make your admin: sign up in the app, then run `DATABASE_URL="<url>" node db/make-admin.js you@email.com` from your computer.
8. Put the service's address into the Flutter app as its base URL. Use `https://`, because Android blocks plain `http://` to real servers by default.

With Docker instead: `JWT_SECRET=<long random text> docker compose up -d --build` starts the database and the API together.

## Known limits (shortcuts to revisit)
- Login rate limiting is counted in one server's memory. With several servers, use a shared store.
- No audit log of admin actions, no password reset, no email verification, no Google login.
- Shop ratings are typed-in numbers; shops have no reviews yet.
- Hike paths are stored as JSON, which is fine for showing a route but not for map searches.
- CORS is open to every website. Mobile apps don't need CORS; restrict it if a web client is added.
- Seed coordinates, waypoints and phone numbers are samples, not surveyed data.
