from __future__ import annotations

from typing import TYPE_CHECKING, Optional, Tuple

import schemas
from services.wellbeing_service import calculate_wellbeing

if TYPE_CHECKING:
    import models


def normalize_lang(lang: str) -> str:
    lang = (lang or "en").lower()
    return lang if lang in {"en", "ru"} else "en"


def _build_recommendation_message(
    index: float,
    last_entry: "models.MoodEntry",
    lang: str,
) -> Tuple[str, str]:
    """Return (level, message) based on index and last entry patterns."""
    high_stress = last_entry.stress >= 7
    low_sleep = (last_entry.sleep_hours or 0) < 6
    low_energy = last_entry.energy <= 4

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


def build_recommendation_response(
    last_entry: Optional["models.MoodEntry"],
    lang: str,
) -> schemas.RecommendationResponse:
    lang = normalize_lang(lang)
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


def build_wellbeing_response(
    last_entry: Optional["models.MoodEntry"],
) -> schemas.WellbeingResponse:
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
