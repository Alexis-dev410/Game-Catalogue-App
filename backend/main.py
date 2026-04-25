from fastapi import FastAPI, HTTPException
from database import SessionLocal
from models import Item

app = FastAPI()

# GET all items
@app.get("/items")
def get_items():
    db = SessionLocal()
    items = db.query(Item).all()
    return items

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