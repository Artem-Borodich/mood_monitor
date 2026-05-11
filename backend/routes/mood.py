from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import desc
from sqlalchemy.orm import Session

import models
import schemas
from database import get_db
from services.recommendation_service import (
    build_recommendation_response,
    build_wellbeing_response,
)

router = APIRouter()


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
        category=payload.category,
        sleep_hours=payload.sleep_hours,
        activity_minutes=payload.activity_minutes,
    )
    if payload.created_at is not None:
        db_entry.created_at = payload.created_at

    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry


@router.get("/mood", response_model=List[schemas.MoodEntryRead])
def list_mood_entries(
    db: Session = Depends(get_db),
):
    entries = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .all()
    )
    return entries


@router.get("/mood/{entry_id}", response_model=schemas.MoodEntryRead)
def get_mood_entry(
    entry_id: int,
    db: Session = Depends(get_db),
):
    entry = db.query(models.MoodEntry).filter(models.MoodEntry.id == entry_id).first()
    if entry is None:
        raise HTTPException(status_code=404, detail="Entry not found")
    return entry


@router.put("/mood/{entry_id}", response_model=schemas.MoodEntryRead)
def update_mood_entry(
    entry_id: int,
    payload: schemas.MoodEntryCreate,
    db: Session = Depends(get_db),
):
    entry = db.query(models.MoodEntry).filter(models.MoodEntry.id == entry_id).first()
    if entry is None:
        raise HTTPException(status_code=404, detail="Entry not found")
    entry.mood = payload.mood
    entry.stress = payload.stress
    entry.energy = payload.energy
    entry.note = payload.note
    entry.category = payload.category
    entry.sleep_hours = payload.sleep_hours
    entry.activity_minutes = payload.activity_minutes
    if payload.created_at is not None:
        entry.created_at = payload.created_at
    db.commit()
    db.refresh(entry)
    return entry


@router.delete("/mood/{entry_id}", status_code=204)
def delete_mood_entry(
    entry_id: int,
    db: Session = Depends(get_db),
):
    entry = db.query(models.MoodEntry).filter(models.MoodEntry.id == entry_id).first()
    if entry is None:
        raise HTTPException(status_code=404, detail="Entry not found")
    db.delete(entry)
    db.commit()
    return None


@router.get("/wellbeing", response_model=schemas.WellbeingResponse)
def get_current_wellbeing(db: Session = Depends(get_db)):
    last_entry = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .first()
    )
    return build_wellbeing_response(last_entry)


@router.get("/recommendations", response_model=schemas.RecommendationResponse)
def get_recommendations(
    lang: str = Query("en", description="Language code: 'en' or 'ru'"),
    db: Session = Depends(get_db),
):
    last_entry = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .first()
    )
    return build_recommendation_response(last_entry, lang)
