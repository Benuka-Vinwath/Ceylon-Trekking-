# Backend learning path (built from the Figma screens)

Stack from the proposal: Node.js + Express (API) + PostgreSQL (data). Flutter calls the API over HTTP and gets JSON back.

```
Flutter app  --HTTP/JSON-->  Express routes  --SQL-->  PostgreSQL
```

## Run it
1. Get a database (pick one):
   - Docker: start Docker Desktop, then `docker compose up -d` (it runs `db/schema.sql` and `db/seed.sql` for you), or
   - Install PostgreSQL for Windows, create a DB `ceylon_trekking`, and run both `.sql` files with `psql`.
2. `npm install`, then `npm run dev`.
3. Start over any time with `npm run db:reset` (wipes the DB, reloads schema.sql + seed.sql; dev only).
4. Open http://localhost:3000/api/treks and http://localhost:3000/api/treks?difficulty=Easy

## Lessons, in build order (each one maps to Figma screens)
| # | Topic | Screens | What you learn |
|---|-------|---------|----------------|
| 1 | Routes + SQL read (DONE) | 06 Home, 07 Search, 08 Trek Details | HTTP verbs, Express routing, `SELECT`, query params, parameterised queries, status codes |
| 2 | Auth (DONE) | 04 Login, 05 Sign Up | `INSERT`, password hashing (bcrypt), JWT tokens, middleware, roles |
| 3 | Reviews + saved treks (DONE) | 09, 10, 20 | Foreign keys, `JOIN`, `AVG`, protected routes, `UNIQUE` constraints |
| 4 | Parking + gear shops (DONE) | 15-18 | Geo data, "nearby" queries (lat/lng distance), one-to-many |
| 5 | Equipment booking | proposal's rental feature | Transactions, date-overlap checks, keeping bookings accurate |
| 6 | Admin | 21 Admin Dashboard | Role-based access, `COUNT` stats, moderation |
| 7 | Production basics | all | Validation, error handling, env config, deployment, offline-map file serving |

## Files to read first
- `db/schema.sql`: the data model. Design this before any code.
- `src/routes/treks.js`: one request, start to finish.
- `src/app.test.js`: how to test an API without a database.
