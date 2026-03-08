from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import desc
from sqlalchemy.orm import Session

import models
import schemas
from database import get_db


router = APIRouter()


def calculate_wellbeing(mood: int, stress: int, energy: int) -> float:
    index = 0.4 * mood + 0.3 * energy - 0.3 * stress
    return round(index, 2)


@router.post("/mood", response_model=schemas.MoodEntryRead, status_code=201)
def create_mood_entry(
    payload: schemas.MoodEntryCreate,
    db: Session = Depends(get_db),
):
    db_entry = models.MoodEntry(
        mood=payload.mood,
        stress=payload.stress,
        energy=payload.energy,
        note=payload.note,
    )
    if payload.created_at is not None:
        db_entry.created_at = payload.created_at

    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry


@router.get("/mood", response_model=List[schemas.MoodEntryRead])
def list_mood_entries(db: Session = Depends(get_db)):
    entries = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .all()
    )
    return entries


@router.get("/wellbeing", response_model=schemas.WellbeingResponse)
def get_current_wellbeing(db: Session = Depends(get_db)):
    last_entry = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .first()
    )
    if last_entry is None:
        return schemas.WellbeingResponse(
            wellbeing_index=None,
            based_on_entry_id=None,
        )

    index = calculate_wellbeing(
        mood=last_entry.mood,
        stress=last_entry.stress,
        energy=last_entry.energy,
    )
    return schemas.WellbeingResponse(
        wellbeing_index=index,
        based_on_entry_id=last_entry.id,
    )


@router.get("/recommendations", response_model=schemas.RecommendationResponse)
def get_recommendations(db: Session = Depends(get_db)):
    last_entry = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .first()
    )
    if last_entry is None:
        return schemas.RecommendationResponse(
            wellbeing_index=None,
            level="none",
            message="No mood data yet. Start by recording how you feel today.",
        )

    index = calculate_wellbeing(
        mood=last_entry.mood,
        stress=last_entry.stress,
        energy=last_entry.energy,
    )

    if index < 3:
        message = (
            "Consider taking a break and practicing relaxation techniques."
        )
        level = "low"
    elif index < 6:
        message = "Try light physical activity or a short walk."
        level = "medium"
    else:
        message = (
            "Your emotional state looks stable. Keep maintaining your routine."
        )
        level = "high"

    return schemas.RecommendationResponse(
        wellbeing_index=index,
        level=level,
        message=message,
    )

