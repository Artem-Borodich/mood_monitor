"""Diploma-related HTTP routes (thin): forecast, advice feedback."""

from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy import desc
from sqlalchemy.orm import Session

import models
import schemas
from database import get_db
from services.forecast_service import forecast_from_entries
from services.recommendation_service import normalize_lang

router = APIRouter(tags=["diploma"])


def _entries_for_forecast(db: Session, limit: int = 14) -> List[models.MoodEntry]:
    return (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .limit(limit)
        .all()
    )


@router.get("/forecast", response_model=schemas.ForecastRead)
def get_forecast(
    user_id: int = 1,
    lang: str = "en",
    db: Session = Depends(get_db),
):
    """Rule-based next-day risk from recent mood entries (`user_id` reserved for future scoping)."""
    _ = user_id
    lang = normalize_lang(lang)
    entries = _entries_for_forecast(db)
    return forecast_from_entries(entries, lang)


@router.post("/feedback", status_code=201)
def post_feedback(payload: schemas.FeedbackCreate):
    """Accept advice feedback (extend later with persistence if needed)."""
    _ = payload
    return {"status": "received"}
