from sqlalchemy import Column, Integer, String, Float, Text, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func

Base = declarative_base()

class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)
    year = Column(Integer, nullable=False)
    rating = Column(Float, nullable=False)
    description = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())