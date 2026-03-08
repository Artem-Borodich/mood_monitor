from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import and_, desc
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


def _build_recommendation_message(
    index: float,
    last_entry: models.MoodEntry,
    lang: str,
) -> tuple[str, str]:
    """Return (level, message) based on index and last entry patterns."""
    # Simple pattern examples:
    high_stress = last_entry.stress >= 7
    low_sleep = (last_entry.sleep_hours or 0) < 6
    low_energy = last_entry.energy <= 4

    # Russian texts
    if lang == "ru":
        if high_stress and low_sleep:
            return (
                "low",
                "Стресс высокий, а сна мало. Попробуйте сегодня лечь спать раньше и исключить экраны за 1 час до сна.",
            )
        if high_stress and last_entry.category == "work":
            return (
                "medium",
                "Частый стресс, связанный с работой. Сделайте короткий перерыв, пройдитесь или выполните дыхательное упражнение 4–7–8.",
            )
        if low_energy and (last_entry.activity_minutes or 0) == 0:
            return (
                "medium",
                "Энергия низкая. Короткая прогулка или мягкая растяжка на 10–15 минут могут помочь взбодриться.",
            )
        if index < 3:
            return (
                "low",
                "Ваш индекс благополучия сейчас низкий. Найдите 5–10 минут, чтобы сделать что‑то приятное и снизить нагрузку.",
            )
        if index < 6:
            return (
                "medium",
                "Состояние среднее. Подумайте, что помогало вам отдыхать раньше, и запланируйте это сегодня.",
            )
        return (
            "high",
            "Ваше состояние выглядит стабильным. Продолжайте поддерживать полезные привычки и отслеживать своё самочувствие.",
        )

    # English texts (default)
    if high_stress and low_sleep:
        return (
            "low",
            "Stress is high and sleep is low. Try going to bed earlier tonight and avoiding screens 1 hour before sleep.",
        )
    if high_stress and last_entry.category == "work":
        return (
            "medium",
            "You often report work‑related stress. Take a short break, walk a bit, or try a 4‑7‑8 breathing exercise.",
        )
    if low_energy and (last_entry.activity_minutes or 0) == 0:
        return (
            "medium",
            "Your energy is low. A 10–15 minute walk or light stretching may help you feel more awake.",
        )
    if index < 3:
        return (
            "low",
            "Your wellbeing index is low. Try to slow down, take a break and do something pleasant for yourself.",
        )
    if index < 6:
        return (
            "medium",
            "Your state is in the middle. Consider scheduling a short rest or activity that usually helps you recharge.",
        )
    return (
        "high",
        "Your emotional state looks stable. Keep maintaining the habits that support your wellbeing.",
    )


@router.get("/recommendations", response_model=schemas.RecommendationResponse)
def get_recommendations(
    lang: str = Query("en", description="Language code: 'en' or 'ru'"),
    db: Session = Depends(get_db),
):
    lang = lang.lower()
    if lang not in {"en", "ru"}:
        lang = "en"

    last_entry = (
        db.query(models.MoodEntry)
        .order_by(desc(models.MoodEntry.created_at))
        .first()
    )
    if last_entry is None:
        message = (
            "Пока нет данных. Начните с первой записи о самочувствии."
            if lang == "ru"
            else "No mood data yet. Start by recording how you feel today."
        )
        return schemas.RecommendationResponse(
            wellbeing_index=None,
            level="none",
            message=message,
        )

    index = calculate_wellbeing(
        mood=last_entry.mood,
        stress=last_entry.stress,
        energy=last_entry.energy,
    )

    level, message = _build_recommendation_message(index, last_entry, lang)

    return schemas.RecommendationResponse(
        wellbeing_index=index,
        level=level,
        message=message,
    )

