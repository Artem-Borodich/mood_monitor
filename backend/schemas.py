from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class MoodEntryCreate(BaseModel):
    mood: int = Field(..., ge=1, le=10)
    stress: int = Field(..., ge=1, le=10)
    energy: int = Field(..., ge=1, le=10)
    note: Optional[str] = None
    # Optional category/tag for the entry (e.g. "work", "relationships", "health").
    category: Optional[str] = Field(default=None, max_length=50)
    # Optional number of hours of sleep (0–24).
    sleep_hours: Optional[float] = Field(default=None, ge=0, le=24)
    # Optional number of minutes of physical activity (0–1440).
    activity_minutes: Optional[int] = Field(default=None, ge=0, le=1440)
    created_at: Optional[datetime] = None


class MoodEntryRead(BaseModel):
    id: int
    mood: int
    stress: int
    energy: int
    note: Optional[str]
    category: Optional[str]
    sleep_hours: Optional[float]
    activity_minutes: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True


class WellbeingResponse(BaseModel):
    wellbeing_index: Optional[float]
    based_on_entry_id: Optional[int]


class RecommendationResponse(BaseModel):
    wellbeing_index: Optional[float]
    level: str
    message: str

