from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session
from database import SessionLocal, engine
from models import Item, Base
import pandas as pd
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime

# Ensure tables are created on startup
Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for validation
class ItemBase(BaseModel):
    title: str
    category: str
    year: int
    rating: float = Field(ge=0, le=10)
    description: Optional[str] = None
    platform: Optional[str] = None

class ItemResponse(ItemBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/items", response_model=List[ItemResponse])
def get_items(
    category: Optional[str] = None,
    search: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(100, ge=1),
    db: Session = Depends(get_db)
):
    query = db.query(Item).order_by(Item.id.desc())
    if category and category != "All":
        query = query.filter(Item.category == category)
    if search:
        query = query.filter(Item.title.contains(search))
    skip = (page - 1) * limit
    return query.offset(skip).limit(limit).all()

@app.get("/items/{item_id}", response_model=ItemResponse)
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@app.post("/items", response_model=ItemResponse, status_code=201)
def create_item(item_data: ItemBase, db: Session = Depends(get_db)):
    try:
        new_item = Item(**item_data.model_dump())
        db.add(new_item)
        db.commit()
        db.refresh(new_item)
        return new_item
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/items/{item_id}", response_model=ItemResponse)
def update_item(item_id: int, updated_data: ItemBase, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    # Update attributes
    for key, value in updated_data.model_dump().items():
        setattr(item, key, value)

    try:
        db.commit()
        db.refresh(item)
        return item
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Update failed: {str(e)}")

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
        return {"total_items": 0, "average_rating": 0, "by_category": {}, "top_rated": [], "most_recent": None}

    data = [{"title": i.title, "category": i.category, "rating": i.rating, "created_at": i.created_at} for i in items]
    df = pd.DataFrame(data)

    return {
        "total_items": len(df),
        "average_rating": round(float(df["rating"].mean()), 2),
        "by_category": df["category"].value_counts().to_dict(),
        "top_rated": df.sort_values(by="rating", ascending=False).head(3)[["title", "rating"]].to_dict(orient="records"),
        "most_recent": {
            "title": df.sort_values(by="created_at", ascending=False).iloc[0]["title"],
            "created_at": str(df.sort_values(by="created_at", ascending=False).iloc[0]["created_at"])
        }
    }
