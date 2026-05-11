"""Diploma-related endpoints: forecast, advice feedback."""

from __future__ import annotations

from datetime import date, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import desc
from sqlalchemy.orm import Session

import models
from database import get_db
from routes.mood import calculate_wellbeing

router = APIRouter(tags=["diploma"])


class ForecastFactorOut(BaseModel):
    name: str
    impact: str


class ForecastOut(BaseModel):
    status: str
    risk: Optional[float] = None
    label: Optional[str] = None
    threshold: float = 0.5
    factors: Optional[List[ForecastFactorOut]] = None
    explanation: Optional[str] = None
    target_date: Optional[str] = None

    model_config = ConfigDict(populate_by_name=True)


class FeedbackCreate(BaseModel):
    user_id: int = Field(..., ge=1)
    advice_id: str = Field(..., min_length=1, max_length=128)
    feedback: str = Field(..., min_length=1, max_length=2000)


def _entries_for_forecast(db: Session, limit: int = 14) -> List[models.MoodEntry]:
    return (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .limit(limit)
        .all()
    )


def _forecast_from_entries(
    entries: List[models.MoodEntry],
    lang: str,
) -> ForecastOut:
    if not entries:
        if lang == "ru":
            msg = "Недостаточно записей для прогноза. Добавьте несколько дней настроения."
        else:
            msg = "Not enough entries for a forecast. Log a few more days of mood."
        return ForecastOut(status="insufficient_data", explanation=msg)

    # Chronological order (oldest first) for trends
    chrono = list(reversed(entries))
    n = len(chrono)
    avg_mood = sum(e.mood for e in chrono) / n
    avg_stress = sum(e.stress for e in chrono) / n
    sleeps = [e.sleep_hours for e in chrono if e.sleep_hours is not None]
    avg_sleep = sum(sleeps) / len(sleeps) if sleeps else None

    trend_penalty = 0.0
    if n >= 6:
        mid = n // 2
        early_m = sum(e.mood for e in chrono[:mid]) / mid
        late_m = sum(e.mood for e in chrono[mid:]) / (n - mid)
        if late_m < early_m - 0.5:
            trend_penalty = 0.12

    sleep_component = 0.0
    if avg_sleep is not None:
        sleep_component = max(0.0, min(1.0, (6.5 - avg_sleep) / 6.5)) * 0.22

    risk = (
        0.38 * (avg_stress / 10.0)
        + 0.28 * ((10.0 - avg_mood) / 10.0)
        + sleep_component
        + trend_penalty
    )
    risk = max(0.05, min(0.92, round(risk, 3)))

    factors: List[ForecastFactorOut] = []
    if avg_stress >= 6.5:
        factors.append(
            ForecastFactorOut(
                name="stress" if lang != "ru" else "стресс",
                impact="negative",
            )
        )
    if avg_mood <= 5.0:
        factors.append(
            ForecastFactorOut(
                name="mood" if lang != "ru" else "настроение",
                impact="negative",
            )
        )
    if avg_sleep is not None and avg_sleep < 6.5:
        factors.append(
            ForecastFactorOut(
                name="sleep" if lang != "ru" else "сон",
                impact="negative",
            )
        )
    if trend_penalty > 0:
        factors.append(
            ForecastFactorOut(
                name="trend" if lang != "ru" else "тренд",
                impact="negative",
            )
        )
    if not factors:
        factors.append(
            ForecastFactorOut(
                name="patterns" if lang != "ru" else "паттерны",
                impact="neutral",
            )
        )

    if risk >= 0.55:
        label = "elevated"
    elif risk >= 0.35:
        label = "moderate"
    else:
        label = "low"

    tomorrow = (date.today() + timedelta(days=1)).isoformat()

    if lang == "ru":
        if risk >= 0.55:
            expl = (
                "По последним записям завтра возможен перегруз: высокий стресс или недосып "
                "снижают запас устойчивости."
            )
        elif risk >= 0.35:
            expl = (
                "Умеренный риск снижения самочувствия: обратите внимание на сон и паузы в течение дня."
            )
        else:
            expl = (
                "Риск относительно низкий. Поддерживайте текущие привычки и мягкий режим дня."
            )
    else:
        if risk >= 0.55:
            expl = (
                "Based on recent logs, tomorrow may feel heavier: stress or short sleep "
                "reduces your buffer."
            )
        elif risk >= 0.35:
            expl = (
                "Moderate risk of a dip: prioritize sleep and short breaks during the day."
            )
        else:
            expl = (
                "Risk looks relatively low. Keep steady habits and a gentle pace tomorrow."
            )

    return ForecastOut(
        status="ok",
        risk=risk,
        label=label,
        threshold=0.5,
        factors=factors,
        explanation=expl,
        target_date=tomorrow,
    )


@router.get("/forecast", response_model=ForecastOut)
def get_forecast(
    user_id: int = 1,
    lang: str = "en",
    db: Session = Depends(get_db),
):
    """Rule-based next-day risk from recent mood entries (`user_id` reserved for future scoping)."""
    _ = user_id
    lang = lang.lower() if lang else "en"
    if lang not in {"en", "ru"}:
        lang = "en"
    entries = _entries_for_forecast(db)
    return _forecast_from_entries(entries, lang)


@router.post("/feedback", status_code=201)
def post_feedback(payload: FeedbackCreate):
    """Accept advice feedback (stored client-side or extended later with a DB table)."""
    _ = payload
    return {"status": "received"}
