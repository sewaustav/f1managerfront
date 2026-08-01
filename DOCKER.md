# Running the full stack with Docker

Brings up Postgres, Redis, the Go backend, and the Flutter web frontend with one
command. Assumes the two repos are checked out side by side:

```
<parent>/f1manager        # backend
<parent>/f1managerfront    # frontend  (run compose from here)
```

## Quick start

```bash
docker compose up --build
```

Then open:

- **Frontend:** http://localhost:8081
- **Backend API:** http://localhost:8080/api/v1

Stop with `Ctrl-C`; tear down (including data) with `docker compose down -v`.

## What each piece does

| Service | Image / build | Port | Notes |
|---|---|---|---|
| `db` | postgres:16-alpine | 5432 | schema auto-applied from the backend migration on first boot |
| `redis` | redis:7-alpine | 6379 | dynamic game state |
| `backend` | `../f1manager/Dockerfile` | 8080 | generates JWT keys on first run into the `jwtkeys` volume |
| `frontend` | `./Dockerfile` (nginx) | 8081 | `API_HOST` baked at build time = `localhost:8080` |

`CORS_ORIGINS` on the backend is set to the frontend's published origin
(`http://localhost:8081`) so browser requests pass CORS. If you change the
frontend port, update **both** the `frontend` port mapping and `CORS_ORIGINS`.

## Seeding

Static game data (pilots, tracks, engines, principals, base teams, pilot/track
ratings) is seeded **automatically on first boot** from
`../f1manager/initial_data/seed_postgres.sql`, mounted into the db's
`docker-entrypoint-initdb.d/` right after the schema. No manual step — the draft
has content out of the box.

That SQL was generated from the bundled, already-populated
`f1manager/f1_simulation.db` (SQLite) and mirrors it into Postgres with the same
ids (so `pilots_track_initial` FKs line up). To regenerate it after changing the
source data, dump the six static tables (`pilots_initial`, `tracks`, `engine`,
`teams_principals`, `base_team`, `pilots_track_initial`) to
`initial_data/seed_postgres.sql` in insert form.

> Seeding (like the schema) only runs when the `pgdata` volume is first created.
> After changing the seed, `docker compose down -v && docker compose up --build`.

Note: `cmd/data/seed.go` seeds **SQLite** (the old sim/CLI path), not this
Postgres stack — it is unrelated to the compose seeding above.

## Re-applying the schema

The schema migration only runs when the `pgdata` volume is first created. To
re-apply after changing the migration:

```bash
docker compose down -v && docker compose up --build
```

## Common tweaks

- **Change ports:** edit the `ports:` mappings; keep `API_HOST` (frontend build
  arg) and `CORS_ORIGINS` (backend env) in sync with the new backend/frontend
  ports.
- **Rebuild one service:** `docker compose build backend` / `frontend`.
- **Logs:** `docker compose logs -f backend`.
