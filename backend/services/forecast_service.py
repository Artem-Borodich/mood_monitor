"""Rule-based next-day risk from recent mood entries."""

from __future__ import annotations

from datetime import date, timedelta
from typing import TYPE_CHECKING, List

import schemas

if TYPE_CHECKING:
    import models

# Heuristic weights (documented constants instead of magic numbers in expressions).
RISK_STRESS_COEF = 0.38
RISK_MOOD_COEF = 0.28
RISK_SLEEP_COEF = 0.22
SLEEP_TARGET_H = 6.5
TREND_DROP_THRESHOLD = 0.5
TREND_PENALTY = 0.12
RISK_MIN = 0.05
RISK_MAX = 0.92
STRESS_FACTOR_THRESHOLD = 6.5
MOOD_FACTOR_THRESHOLD = 5.0
LABEL_ELEVATED = 0.55
LABEL_MODERATE = 0.35


def forecast_from_entries(
    entries: List["models.MoodEntry"],
    lang: str,
) -> schemas.ForecastRead:
    if not entries:
        if lang == "ru":
            msg = "Недостаточно записей для прогноза. Добавьте несколько дней настроения."
        else:
            msg = "Not enough entries for a forecast. Log a few more days of mood."
        return schemas.ForecastRead(status="insufficient_data", explanation=msg)

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
        if late_m < early_m - TREND_DROP_THRESHOLD:
            trend_penalty = TREND_PENALTY

    sleep_component = 0.0
    if avg_sleep is not None:
        sleep_component = (
            max(0.0, min(1.0, (SLEEP_TARGET_H - avg_sleep) / SLEEP_TARGET_H))
            * RISK_SLEEP_COEF
        )

    risk = (
        RISK_STRESS_COEF * (avg_stress / 10.0)
        + RISK_MOOD_COEF * ((10.0 - avg_mood) / 10.0)
        + sleep_component
        + trend_penalty
    )
    risk = max(RISK_MIN, min(RISK_MAX, round(risk, 3)))

    factors: List[schemas.ForecastFactorRead] = []
    if avg_stress >= STRESS_FACTOR_THRESHOLD:
        factors.append(
            schemas.ForecastFactorRead(
                name="stress" if lang != "ru" else "стресс",
                impact="negative",
            )
        )
    if avg_mood <= MOOD_FACTOR_THRESHOLD:
        factors.append(
            schemas.ForecastFactorRead(
                name="mood" if lang != "ru" else "настроение",
                impact="negative",
            )
        )
    if avg_sleep is not None and avg_sleep < SLEEP_TARGET_H:
        factors.append(
            schemas.ForecastFactorRead(
                name="sleep" if lang != "ru" else "сон",
                impact="negative",
            )
        )
    if trend_penalty > 0:
        factors.append(
            schemas.ForecastFactorRead(
                name="trend" if lang != "ru" else "тренд",
                impact="negative",
            )
        )
    if not factors:
        factors.append(
            schemas.ForecastFactorRead(
                name="patterns" if lang != "ru" else "паттерны",
                impact="neutral",
            )
        )

    if risk >= LABEL_ELEVATED:
        label = "elevated"
    elif risk >= LABEL_MODERATE:
        label = "moderate"
    else:
        label = "low"

    tomorrow = (date.today() + timedelta(days=1)).isoformat()

    if lang == "ru":
        if risk >= LABEL_ELEVATED:
            expl = (
                "По последним записям завтра возможен перегруз: высокий стресс или недосып "
                "снижают запас устойчивости."
            )
        elif risk >= LABEL_MODERATE:
            expl = (
                "Умеренный риск снижения самочувствия: обратите внимание на сон и паузы в течение дня."
            )
        else:
            expl = (
                "Риск относительно низкий. Поддерживайте текущие привычки и мягкий режим дня."
            )
    else:
        if risk >= LABEL_ELEVATED:
            expl = (
                "Based on recent logs, tomorrow may feel heavier: stress or short sleep "
                "reduces your buffer."
            )
        elif risk >= LABEL_MODERATE:
            expl = (
                "Moderate risk of a dip: prioritize sleep and short breaks during the day."
            )
        else:
            expl = (
                "Risk looks relatively low. Keep steady habits and a gentle pace tomorrow."
            )

    return schemas.ForecastRead(
        status="ok",
        risk=risk,
        label=label,
        threshold=0.5,
        factors=factors,
        explanation=expl,
        target_date=tomorrow,
    )
