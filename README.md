## Psycho-emotional State Monitor MVP

Minimal full-stack prototype for tracking a single user's psycho-emotional state.

Technologies:
- **Backend**: Python, FastAPI, SQLAlchemy, PostgreSQL
- **Mobile**: Flutter, Dart, Material UI, `fl_chart`

Project structure:
- **backend/**: FastAPI application
- **flutter_app/**: Flutter mobile client

---

## Backend

### Prerequisites

- Python 3.10+
- PostgreSQL running locally

Create a PostgreSQL database, for example:

```sql
CREATE DATABASE mood_db;
```

By default, the app uses this connection string:

```text
postgresql+psycopg2://postgres:postgres@localhost:5432/mood_db
```

You can override it via `DATABASE_URL` environment variable.

### Install dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Run backend

```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`.

Main endpoints:
- **GET** `/health` – simple `{ "status": "ok" }` connectivity check
- **POST** `/mood` – create mood entry
- **GET** `/mood` – list all entries
- **GET** `/wellbeing` – current wellbeing index (from latest entry)
- **GET** `/recommendations` – recommendation text based on wellbeing index

Wellbeing index formula:

\[
\text{wellbeing\_index} = 0.4 \cdot \text{mood} + 0.3 \cdot \text{energy} - 0.3 \cdot \text{stress}
\]

---

## Flutter App

### Prerequisites

- Flutter SDK installed

### Install dependencies

```bash
cd flutter_app
flutter pub get
```

Make sure the backend is running.

**API base URL** is resolved automatically in `lib/core/app_config.dart`:

- Android emulator → `http://10.0.2.2:8000`
- iOS / Windows / macOS / Linux → `http://localhost:8000`
- Web → `http://localhost:8000`

Override for any platform (e.g. physical phone on Wi‑Fi):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

The app uses **Google Fonts** (Inter + Plus Jakarta Sans, loaded at runtime), **shimmer** skeletons while data loads, **Material 3** `NavigationBar`, and **light/dark** theme (see Settings). Locale date formats use `intl` (initialized for `en` and `ru` in `main()`).

### Run app

From `flutter_app`:

```bash
flutter run
```

### Screens

- **DashboardScreen**
  - Shows wellbeing index
  - Shows mood line chart over time
  - Shows latest mood entry
- **AddMoodScreen**
  - Add mood (1–10), stress (1–10), energy (1–10), optional note, date
- **HistoryScreen**
  - List all entries with date, mood, stress, energy, note
- **RecommendationsScreen**
  - Shows simple recommendations from backend based on wellbeing index

