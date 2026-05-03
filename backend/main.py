from fastapi import FastAPI, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Item
import pandas as pd
from typing import List, Optional

app = FastAPI()

# Dependency to get DB session and ensure it closes
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/items")
def get_items(
    category: Optional[str] = None,
    search: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1),
    db: Session = Depends(get_db)
):
    query = db.query(Item)

    if category and category != "All":
        query = query.filter(Item.category == category)

    if search:
        query = query.filter(Item.title.contains(search))

    # Pagination logic
    skip = (page - 1) * limit
    return query.offset(skip).limit(limit).all()

@app.get("/items/{item_id}")
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@app.post("/items", status_code=201)
def create_item(item_data: dict, db: Session = Depends(get_db)):
    try:
        new_item = Item(**item_data)
        db.add(new_item)
        db.commit()
        db.refresh(new_item)
        return new_item
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/items/{item_id}")
def update_item(item_id: int, updated_data: dict, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    for key, value in updated_data.items():
        if hasattr(item, key):
            setattr(item, key, value)

    db.commit()
    db.refresh(item)
    return item

@app.delete("/items/{item_id}")
def delete_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    db.delete(item)
    db.commit()
    return {"message": "Item deleted"}

@app.get("/stats")
def get_stats(db: Session = Depends(get_db)):
    items = db.query(Item).all()
    if not items:
        return {
            "total_items": 0,
            "average_rating": 0,
            "by_category": {},
            "top_rated": [],
            "most_recent": None
        }

    # Convert to DataFrame
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

    stats = {
        "total_items": len(df),
        "average_rating": round(float(df["rating"].mean()), 2),
        "by_category": df["category"].value_counts().to_dict(),
        "top_rated": df.sort_values(by="rating", ascending=False).head(3)[["title", "rating"]].to_dict(orient="records"),
        "most_recent": {
            "title": df.sort_values(by="created_at", ascending=False).iloc[0]["title"],
            "created_at": str(df.sort_values(by="created_at", ascending=False).iloc[0]["created_at"])
        }
    }
    return stats
