A full-stack game-catalog application where users can browse and search games, filter by category, view details, add or edit catalog entries, and keep a favourites list. A dashboard displays catalog statistics, including ratings and category totals.


## Start the application

### Prerequisites

- Python 3 and MySQL Server
- Flutter SDK
- An Android emulator or device (the app is configured for the Android emulator)

### 1. Prepare MySQL

Create the database if it does not already exist:

```sql
CREATE DATABASE IF NOT EXISTS catalog_db;
```

Configure the MySQL connection in `backend/database.py` to match your local server and credentials before starting the API.

### 2. Start the backend

From the project folder, open a terminal and run:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Keep this terminal running. The API documentation is available at [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs).

### 3. Start the Flutter app

In a second terminal, from the project folder, run:

```powershell
cd flutter_app
flutter pub get
flutter run
```

The Android emulator connects to the API at `10.0.2.2:8000`. A physical device needs a reachable backend address configured in the Flutter app instead.

### Optional: load sample games

To replace the database's current catalog with the sample games, stop the backend and run:

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
python seed.py
```

**Warning:** `seed.py` deletes existing catalog items before inserting the sample data.