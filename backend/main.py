from fastapi import FastAPI, HTTPException
from database import SessionLocal
from models import Item
from fastapi import Query
import pandas as pd
app = FastAPI()


@app.get("/items")
def get_items(category: str = None, search: str = None):
    db = SessionLocal()
    query = db.query(Item)

    if category:
        query = query.filter(Item.category == category)

    if search:
        query = query.filter(Item.title.contains(search))

    return query.all()

# GET one item
@app.get("/items/{item_id}")
def get_item(item_id: int):
    db = SessionLocal()
    item = db.query(Item).filter(Item.id == item_id).first()

    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    return item

# POST create item
@app.post("/items", status_code=201)
def create_item(item: dict):
    db = SessionLocal()

    new_item = Item(**item)
    db.add(new_item)
    db.commit()

    return {"message": "Item created"}

@app.put("/items/{item_id}")
def update_item(item_id: int, updated_item: dict):
    db = SessionLocal()
    item = db.query(Item).filter(Item.id == item_id).first()

    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    for key, value in updated_item.items():
        setattr(item, key, value)

    db.commit()
    return {"message": "Item updated"}

@app.get("/stats")
def get_stats():
    db = SessionLocal()
    items = db.query(Item).all()

    if not items:
        return {"message": "No data"}

    # convert items to list of dicts
    data = [
        {
            "title": i.title,
            "category": i.category,
            "rating": i.rating,
            "created_at": i.created_at
        }
        for i in items
    ]

    df = pd.DataFrame(data)

    # total items
    total_items = len(df)

    # average rating
    average_rating = round(df["rating"].mean(), 2)

    # items per category
    by_category = df["category"].value_counts().to_dict()

    # top 3 highest-rated
    top_rated = (
        df.sort_values(by="rating", ascending=False)
        .head(3)[["title", "rating"]]
        .to_dict(orient="records")
    )

    # most recent item
    most_recent_row = df.sort_values(by="created_at", ascending=False).iloc[0]
    most_recent = {
        "title": most_recent_row["title"],
        "created_at": str(most_recent_row["created_at"])
    }

    return {
        "total_items": total_items,
        "average_rating": average_rating,
        "by_category": by_category,
        "top_rated": top_rated,
        "most_recent": most_recent
    }

@app.delete("/items/{item_id}")
def delete_item(item_id: int):
    db = SessionLocal()
    item = db.query(Item).filter(Item.id == item_id).first()

    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    db.delete(item)
    db.commit()

    return {"message": "Item deleted"}