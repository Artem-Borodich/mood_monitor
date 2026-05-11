"""
Детерминированные тестовые записи настроения за ~14 дней:
первая половина периода — стабильно лучше, вторая — заметное ухудшение
(для графиков по дням и для /forecast: стресс, сон, тренд настроения).

Запуск из каталога backend:
  python seed_demo_timeline.py              # добавить, если записей <= 5
  python seed_demo_timeline.py --replace    # очистить mood_entries и вставить демо

Переменные окружения: как у приложения (DATABASE_URL через config.settings).
"""
from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import delete

from database import SessionLocal
import models

# days_ago: 13 = самая старая запись, 0 = сегодня (хронология как в прогнозе после reverse)
# mood 1–10, stress 1–10, energy 1–10, sleep_hours, note, category, activity_minutes
DEMO_DAYS: list[tuple[int, int, int, int, float | None, str | None, str | None, int | None]] = [
    (13, 8, 3, 7, 8.0, "Спокойный день", "health", 25),
    (12, 9, 2, 8, 8.0, "Выспался", "health", 40),
    (11, 8, 4, 7, 7.5, "Работа норм", "work", 20),
    (10, 9, 3, 8, 8.0, "Прогулка", "health", 45),
    (9, 8, 3, 7, 7.5, None, "work", 15),
    (8, 8, 4, 6, 7.5, "Стабильно", "work", 10),
    (7, 9, 2, 8, 8.0, "Хороший отдых", "health", 30),
    # ниже — «тяжелее»: ниже настроение, выше стресс, меньше сна (тренд вниз для forecast)
    (6, 7, 5, 6, 6.5, "Начался завал", "work", 10),
    (5, 6, 6, 5, 6.0, "Мало сна", "work", 0),
    (4, 6, 7, 5, 5.5, "Дедлайны", "work", 0),
    (3, 5, 7, 4, 5.5, "Усталость", "work", 5),
    (2, 5, 8, 4, 5.0, "Короткая ночь", "work", 0),
    (1, 4, 8, 3, 4.5, "На пределе", "work", 0),
    (0, 4, 8, 3, 4.5, "Сегодня тяжело", "work", 10),
]


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed demo mood timeline for charts + forecast.")
    parser.add_argument(
        "--replace",
        action="store_true",
        help="Delete all mood_entries, then insert demo rows.",
    )
    parser.add_argument(
        "--force-append",
        action="store_true",
        help="Append demo even if there are already many entries.",
    )
    args = parser.parse_args()

    db = SessionLocal()
    try:
        count = db.query(models.MoodEntry).count()
        if args.replace:
            db.execute(delete(models.MoodEntry))
            db.commit()
            count = 0
            print("Cleared mood_entries.")
        elif count > 5 and not args.force_append:
            print(
                f"Already {count} entries. Use --replace to wipe and seed, "
                "or --force-append to add demo anyway. Exit."
            )
            return

        now = datetime.now(timezone.utc)
        added = 0
        for days_ago, mood, stress, energy, sleep_h, note, category, activity in DEMO_DAYS:
            day = (now - timedelta(days=days_ago)).date()
            created_at = datetime(
                day.year,
                day.month,
                day.day,
                12,
                0,
                0,
                tzinfo=timezone.utc,
            )
            db.add(
                models.MoodEntry(
                    mood=mood,
                    stress=stress,
                    energy=energy,
                    note=note,
                    category=category,
                    sleep_hours=sleep_h,
                    activity_minutes=activity,
                    created_at=created_at,
                )
            )
            added += 1
        db.commit()
        print(f"Inserted {added} demo mood entries (last {len(DEMO_DAYS)} calendar days).")
    finally:
        db.close()


if __name__ == "__main__":
    main()
