from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import Base, engine
import models  # noqa: F401
from routes import mood as mood_routes


Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Psycho-emotional State Monitor",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(mood_routes.router)

