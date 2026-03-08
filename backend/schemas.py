from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class MoodEntryCreate(BaseModel):
    mood: int = Field(..., ge=1, le=10)
    stress: int = Field(..., ge=1, le=10)
    energy: int = Field(..., ge=1, le=10)
    note: Optional[str] = None
    created_at: Optional[datetime] = None


class MoodEntryRead(BaseModel):
    id: int
    mood: int
    stress: int
    energy: int
    note: Optional[str]
    created_at: datetime

    class Config:
        orm_mode = True


class WellbeingResponse(BaseModel):
    wellbeing_index: Optional[float]
    based_on_entry_id: Optional[int]


class RecommendationResponse(BaseModel):
    wellbeing_index: Optional[float]
    level: str
    message: str

