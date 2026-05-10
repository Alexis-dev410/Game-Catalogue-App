from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# The root password '7ch3sbe' and DB 'catalog_db' must match your MySQL setup
DATABASE_URL = "mysql+mysqlconnector://root:7ch3sbe@127.0.0.1:3306/catalog_db"

# pool_pre_ping=True helps reconnect if the connection goes stale
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()
