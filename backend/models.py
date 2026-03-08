from sqlalchemy import Column, DateTime, Integer, Text
from sqlalchemy.sql import func

from database import Base


class MoodEntry(Base):
    __tablename__ = "mood_entries"

    id = Column(Integer, primary_key=True, index=True)
    mood = Column(Integer, nullable=False)
    stress = Column(Integer, nullable=False)
    energy = Column(Integer, nullable=False)
    note = Column(Text, nullable=True)
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

