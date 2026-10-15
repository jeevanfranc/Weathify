# 🎵 Weathify: Music That Matches Your Weather

Weathify recommends tracks based on your current weather conditions, time of day, and season. A weighted tag-matching engine scores songs stored in PostgreSQL against live conditions and returns ranked matches with relevance scores.

### 🚀 Architecture Overview
*   **Frontend:** Next.js (TypeScript) running on **Port 3000**
*   **Backend:** Node.js / Express running on **Port 5000**
*   **Database:** PostgreSQL running on **Port 5432**

---

## 🛠️ Prerequisites

*   Node.js (>= 18.0.0) & npm (>= 9.0.0)
*   PostgreSQL
*   [Spotify Developer App Credentials](https://developer.spotify.com/dashboard)
*   [OpenWeatherMap API Key](https://openweathermap.org/api)

---

## ⚡ Quick Start

### 1. Clone & Install
```bash
# Clone the repository
git clone <YOUR_REPO_URL>
cd Weathify

# Install backend dependencies
cd backend && npm install

# Install frontend dependencies
cd ../frontend && npm install
cd ..
```

### 2. Configure Environment Variables
Create a `.env` file inside **both** the frontend and backend folders by copying their respective examples.

*   For the **Backend (`backend/.env`)**:
    ```ini
    NODE_ENV=development
    PORT=5000
    DB_HOST=localhost
    DB_PORT=5432
    DB_NAME=weathify_db
    DB_USER=postgres
    DB_PASSWORD=your_postgres_password
    
    # Optional Custom Admin Setup (Defaults to admin/admin123 if blank)
    ADMIN_USER=admin
    ADMIN_EMAIL=admin@weathify.com
    ADMIN_PASS=admin123

    SPOTIFY_CLIENT_ID=your_spotify_client_id
    SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
    SPOTIFY_REDIRECT_URI=http://localhost:5000/callback
    OPENWEATHER_API_KEY=your_openweather_api_key
    
    JWT_SECRET=your_64_char_random_string
    SESSION_SECRET=your_64_char_random_string
    FRONTEND_URL=http://localhost:3000
    ```
*   For the **Frontend (`frontend/.env`)**:
    ```ini
    NEXT_PUBLIC_API_URL=http://localhost:5000
    ```

> 💡 **Tip:** Generate a secure 64-character secret using Node.js:
> `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`

### 3. Initialize the Database
Ensure your local PostgreSQL instance is running, then run the automated setup script from the root directory:
```bash
chmod +x setup.sh
./setup.sh
```
*The script drops/re-creates the database, creates the schema structure, and initializes your administrator profile.*

### 4. Seed Track Library (Optional)
To query songs, seed sample data from Spotify using your configured API credentials:
```bash
node backend/database/seed_songs.js
```

### 5. Launch Development Environments
Open two distinct terminal windows to launch both layers concurrently:
*   **Run Backend:** `cd backend && npm run dev` (Runs on `http://localhost:5000`)
*   **Run Frontend:** `cd frontend && npm run dev` (Runs on `http://localhost:3000`)

---

## 🔑 Default Credentials & Admin Dashboard

*   **Default Admin Username:** `admin`
*   **Default Admin Password:** `admin123`
*   **Admin Platform Route:** `http://localhost:3000/admin.html`

To securely reset or update an administrative password via terminal, utilize the seeder script flag:
```bash
ADMIN_PASS="your_new_secure_password" node backend/database/seed_admin.js --reset
```

---

## 📡 Essential Core API Reference

### User Authentication & Platform Connection
| Method | Endpoint | Payload / Query Parameters | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | `{ username, email, password }` | Registers a new user session profile. |
| `POST` | `/auth/login` | `{ username, password }` | Authenticates user; issues secured httpOnly JWT. |
| `GET` | `/api/spotify/login` | *None* | Redirects the authenticated user to the Spotify OAuth workflow. |
| `GET` | `/api/spotify/callback` | `?code=code&state=state` | Processes incoming Spotify authentication payloads. |

### Recommendation Generation
| Method | Endpoint | Payload / Query Parameters | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/recommendations` | `{ latitude, longitude }` | Fetches live tracks based on localized GPS weather data. |
| `POST` | `/api/recommendations` | `{ weather, season, time_of_day }` | Generates suggestions using user-selected configurations. |

### Administrative Controls (Requires Admin Authorization)
| Method | Endpoint | Payload | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/dashboard/stats` | *None* | Extracts aggregate application tracking analytics. |
| `POST` | `/api/admin/songs` | `{ spotify_track_id }` | Imports a new song asset out of the Spotify library metadata. |
| `POST` | `/api/admin/songs/:id/tags` | `{ tag_id, weight }` | Modifies scoring weights (`1.0` baseline) for weather tags. |

---

## 📈 Recommendation Engine Logic

Tracks carry customized contextual tags mapped to target weather states, timeframes, or seasons. The system processes inputs using a database scoring method where matching weights determine relevancy:

```bash
curl -X POST http://localhost:5000/api/admin/songs/{song_uuid}/tags \
  -H "Content-Type: application/json" \
  -b "adminToken=YOUR_JWT_TOKEN" \
  -d '{"tag_id": "tag_uuid", "weight": 0.85}'
```

---

## 📂 Streamlined Folder Structure

```
weathify/
├── backend/
│   ├── config/database.js          # PostgreSQL engine pool client instances
│   ├── database/
│   │   ├── schema.sql              # Clean table structures, database indexes, tags
│   │   ├── seed_admin.js           # Admin authentication initialization
│   │   └── seed_songs.js           # Target track loader utilizing Spotify context
│   ├── middleware/auth.js          # Route token verification interceptors
│   ├── routes/                     # Modular Express routers (auth, recommendations, admin)
│   ├── services/                   # Scoring matrixes, OpenWeatherMap, & Spotify SDKs
│   └── server.js                   # Application listener root entrypoint
├── frontend/
│   ├── app/                        # Next.js system pages and layouts
│   ├── components/                 # Shared dashboard modular interface components
│   └── package.json                # Next.js application parameters
├── setup.sh                        # Automated Unix environmental initialization script
└── .env.example                    # Template fallback context mapping configuration
```

---

## 🌐 Production Cloud Deployments

The backend layer is fully set up for cloud deployments such as [Railway](https://railway.app/). When hosting in production environments:
1. Ensure your host platform runs your environment on `NODE_ENV=production`.
2. Configure all variables listed in the Environment section directly inside your cloud platform dashboard.
3. Update `SPOTIFY_REDIRECT_URI` to use your production domain: `https://your-backend-service.railway.app/callback`.
4. Ensure the `FRONTEND_URL` points directly to your live production frontend application client domain to maintain correct CORS headers.

---

## 📄 License
Distributed via standard open-source **MIT License** terms.