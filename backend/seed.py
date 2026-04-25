
from database import SessionLocal
from models import Item

db.query(Item).delete()
db.commit()
db = SessionLocal()

items = [
    {
        "title": "The Witcher 3",
        "category": "RPG",
        "year": 2015,
        "rating": 9.8,
        "description": "Open-world fantasy RPG"
    },
    {
        "title": "God of War",
        "category": "Action",
        "year": 2018,
        "rating": 9.6,
        "description": "Mythological action adventure"
    },
    {
        "title": "Minecraft",
        "category": "Sandbox",
        "year": 2011,
        "rating": 9.0,
        "description": "Creative building game"
    }
]

# auto-fill to reach 20 items
for i in range(4, 21):
    items.append({
        "title": f"Game {i}",
        "category": "Action",
        "year": 2020,
        "rating": 7.5,
        "description": "Sample game"
    })

# insert into DB
for item in items:
    db.add(Item(**item))

db.commit()

print("✅ Seeded 20 items!")