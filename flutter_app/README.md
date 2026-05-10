# DBA-W2026-Group - Game Catalog Application

## Domain Choice: Games
This application is a personal catalog for video games. It allows users to browse, search, and filter a collection of games, manage a list of favorites, and view statistics about their catalog.

### Features
- **Browse & Search**: Scroll through all games, search by title, and filter by category (Action, RPG, etc.).
- **Game Details**: View full details including title, year, rating, description, and platform.
- **Favourites**: Mark games as favorites. This state is persisted locally using `shared_preferences`.
- **CRUD Operations**: Add new games, edit existing ones, and delete games from the catalog.
- **Statistics Dashboard**: View data insights powered by Pandas, including total items, average rating, and top-rated games.

---

## Setup Instructions

### 1. Backend (FastAPI + MySQL)
**Prerequisites**: Python 3.x, MySQL Server.

1.  **Navigate to the backend folder**:
    ```bash
    cd backend
    ```
2.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
3.  **Database Configuration**:
    Update `database.py` with your MySQL root password and ensure the database `catalog_db` exists.
4.  **Seed Data** (Optional - to populate 20 items):
    ```bash
    python seed.py
    ```
5.  **Run the server**:
    ```bash
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    ```

### 2. Frontend (Flutter)
**Prerequisites**: Flutter SDK, Android Emulator or Physical Device.

1.  **Navigate to the flutter_app folder**:
    ```bash
    cd flutter_app
    ```
2.  **Get packages**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```
    *Note: The app is configured to connect to `10.0.2.2:8000` for the Android Emulator.*

---

## Project Structure
- `backend/main.py`: FastAPI routes and Pandas logic.
- `backend/models.py`: SQLAlchemy database models.
- `flutter_app/lib/browse_screen.dart`: Main catalog view.
- `flutter_app/lib/item_detail_screen.dart`: Detailed view with Favorite toggle.
- `flutter_app/lib/favourites_screen.dart`: Local persistent favorites list.
- `flutter_app/lib/dashboard_screen.dart`: Analytics dashboard.
