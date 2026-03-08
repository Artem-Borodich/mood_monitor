from sqlalchemy import Column, DateTime, Float, Integer, String, Text
from sqlalchemy.sql import func

from database import Base


class MoodEntry(Base):
    __tablename__ = "mood_entries"

    id = Column(Integer, primary_key=True, index=True)
    mood = Column(Integer, nullable=False)
    stress = Column(Integer, nullable=False)
    energy = Column(Integer, nullable=False)
    note = Column(Text, nullable=True)
    # Optional category/tag for the entry, e.g. "work", "relationships", "health".
    category = Column(String(50), nullable=True, index=True)
    # Optional number of hours of sleep before this entry.
    sleep_hours = Column(Float, nullable=True)
    # Optional number of minutes of physical activity.
    activity_minutes = Column(Integer, nullable=True)
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

