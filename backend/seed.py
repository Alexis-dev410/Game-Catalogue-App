from database import SessionLocal
from models import Item

# Create a session
db = SessionLocal()

try:
    # Clear existing items
    print("Clearing existing items...")
    db.query(Item).delete()
    db.commit()

    # Initial set of games
    items = [
        {
            "title": "The Witcher 3: Wild Hunt",
            "category": "RPG",
            "year": 2015,
            "rating": 9.8,
            "description": "An open-world RPG following Geralt of Rivia.",
            "platform": "PC"
        },
        {
            "title": "God of War",
            "category": "Action",
            "year": 2018,
            "rating": 9.6,
            "description": "Kratos and Atreus in Norse mythology.",
            "platform": "PS4"
        },
        {
            "title": "Minecraft",
            "category": "Sandbox",
            "year": 2011,
            "rating": 9.0,
            "description": "Explore and build in a blocky world.",
            "platform": "Multi"
        },
        {
            "title": "Red Dead Redemption 2",
            "category": "Action",
            "year": 2018,
            "rating": 9.7,
            "description": "Western epic by Rockstar Games.",
            "platform": "PC"
        },
        {
            "title": "The Legend of Zelda: Breath of the Wild",
            "category": "Adventure",
            "year": 2017,
            "rating": 9.9,
            "description": "Open-world adventure in Hyrule.",
            "platform": "Switch"
        }
    ]

    # Fill up to 20 items for Deliverable #1 requirement
    for i in range(len(items) + 1, 21):
        items.append({
            "title": f"Sample Game {i}",
            "category": "Action" if i % 2 == 0 else "RPG",
            "year": 2020 + (i % 5),
            "rating": 7.0 + (i % 3),
            "description": "This is a seeded sample game for testing.",
            "platform": "PC"
        })

    # Insert items
    print(f"Inserting {len(items)} items...")
    for item_data in items:
        db.add(Item(**item_data))

    db.commit()
    print("✅ Successfully seeded 20 games into the database!")

except Exception as e:
    print(f"❌ Error seeding database: {e}")
    db.rollback()
finally:
    db.close()
