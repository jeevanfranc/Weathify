# Weathify

Weathify recommends music using weather, season, and time-of-day context.

Originally a university group project (original repo: [Berketunc/Weathify](https://github.com/Berketunc/Weathify)). The Next.js migration, CI and unit tests were done independently afterwards.

## Architecture

- Frontend: Next.js and TypeScript on port 3000.
- Backend: Node.js and Express on port 5000.
- Database: PostgreSQL on port 5432.

The backend exposes an admin API under `/api/admin`, with no UI, used to import songs and manage tags.

## Requirements

Node.js 18+, npm 9+, PostgreSQL, Spotify Developer App credentials, and an OpenWeatherMap API key.

## Setup

Install dependencies:

```bash
cd backend
npm install
cd ../frontend
npm install
cd ..
```

### Environment files

Create three files:

- Root `.env`: copy `.env.example` (`cp .env.example .env`). It is read by `setup.sh` and needs the database settings (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`) and `ADMIN_PASS`.
- `backend/.env`: read by the backend and the admin seeder.
- `frontend/.env`: read by the Next.js app.

Use the same `DB_NAME` and `DB_PASSWORD` in the root `.env` and `backend/.env`. Never commit any `.env` file.

The backend reads `NODE_ENV`, `PORT`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`, `SPOTIFY_REDIRECT_URI`, `OPENWEATHER_API_KEY`, `JWT_SECRET`, `SESSION_SECRET`, `FRONTEND_URL`, `RATE_LIMIT_WINDOW_MS`, and `RATE_LIMIT_MAX_REQUESTS` from `backend/.env`.

The admin seeder also reads `ADMIN_USER`, `ADMIN_EMAIL`, and `ADMIN_PASS`. There is no default admin password: `ADMIN_PASS` is required in both the root `.env` (for `setup.sh`) and `backend/.env` (for the seeder), and the scripts stop with an error if it is missing. `ADMIN_PASSWORD` is not read.

The Next.js app reads `NEXT_PUBLIC_EXPRESS_API_URL` from `frontend/.env`, normally set to `http://localhost:5000`.

For local Spotify OAuth, set:

```ini
SPOTIFY_REDIRECT_URI=http://127.0.0.1:5000/callback
```

The backend handles the Spotify callback at `/callback` on port 5000, so `SPOTIFY_REDIRECT_URI` must point there. Register the same URL in the Spotify Developer dashboard.

### Database setup

Run this from the repository root with PostgreSQL running, in Git Bash or another bash shell:

```bash
chmod +x setup.sh
./setup.sh
```

`setup.sh` creates the database if it is missing, asks for confirmation before dropping an existing database, applies `backend/database/schema.sql`, and sets the admin password from `ADMIN_PASS`.

The script calls `psql`, which asks for your PostgreSQL password. To avoid repeated prompts, run this first (it only lasts for the current terminal):

```bash
export PGPASSWORD='your_postgres_password'
```

Optional song seeding:

```bash
node backend/database/seed_songs.js
```

### Run the applications

In separate terminals:

```bash
cd backend && npm run dev
cd frontend && npm run dev
```

## API reference

This is a partial list of the 30 Express route declarations.

| Method | Path | Purpose |
|---|---|---|
| POST | `/auth/register` | Register a user. |
| POST | `/auth/login` | Log in a user. |
| GET | `/auth/me` | Get the current user. |
| POST | `/api/recommendations/` | Get recommendations. |
| GET | `/api/recommendations/playlist` | Get liked songs. |
| GET | `/api/spotify/login` | Start Spotify OAuth. |
| GET | `/api/spotify/token` | Get the user's Spotify token. |
| GET | `/api/spotify/profile` | Get the Spotify profile. |
| DELETE | `/api/spotify/disconnect` | Remove the Spotify connection. |
| GET | `/api/admin/songs` | List songs. |
| POST | `/api/admin/songs` | Import a Spotify song. |
| POST | `/api/admin/songs/:id/tags` | Assign a tag to a song. |

## Recommendation scoring

The service scores songs by matching weather tags with weight `3`, season and time-of-day tags with weight `2`, then orders by score and popularity. It loads extra results, limits each artist to two songs, and shuffles the last 20%; database errors use popularity-ordered fallback results. See [docs/ALGORITHM.md](docs/ALGORITHM.md).

## Project structure

```text
weathify/
├── .env.example
├── backend/   # config, database, middleware, routes, services, server.js
├── docs/      # project documentation
├── frontend/  # app, components, hooks, public/css, public/images, types
└── setup.sh
```

## Deployment

The project is not currently hosted. The backend can be deployed to Railway or a similar host.

When deploying, set the environment variables in the hosting service and use the backend service URL for the callback:

```ini
SPOTIFY_REDIRECT_URI=https://your-backend-service.example.com/callback
```

Set `FRONTEND_URL` to the deployed frontend URL so the backend CORS configuration allows it. Register the same callback URL in the Spotify Developer dashboard.

## Project status

### Works

- Registration, login, weather-based recommendations, Spotify connection and in-app playback work locally.
- The backend CI workflow runs lint and the Jest unit tests (recommendation diversity logic) on pushes and pull requests to `main` and `Development`.

### Untested

- No frontend test script or frontend test framework is declared.
- No integration or end-to-end test files were found.

### Planned

- The playlist and profile pages are not yet migrated to Next.js and are currently unavailable. The backend playlist API already exists.

## License

MIT.
