"""
Seed mood_entries with data for the past days to get fuller statistics.
Run once: python seed_past_entries.py
Uses DATABASE_URL from environment or default.
"""
import os
import random
import sys
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
import models

# Past days to fill (one entry per day, sometimes two)
DAYS_BACK = 35
CATEGORIES = [None, "work", "work", "relationships", "health"]
NOTES = [
    None,
    None,
    "Good day",
    "Tired",
    "Focused",
    "Relaxed",
    "Busy at work",
    "Nice walk",
    "Slept well",
    "Short sleep",
]


def main():
    db = SessionLocal()
    try:
        existing = db.query(models.MoodEntry).count()
        if existing > 10:
            print(f"Already {existing} entries. Run seed only on empty/small DB. Exit.")
            return
        now = datetime.now(timezone.utc)
        added = 0
        for d in range(DAYS_BACK, 0, -1):
            date = now - timedelta(days=d)
            # 1 or 2 entries per day
            for _ in range(random.choice([1, 1, 1, 2])):
                mood = random.randint(3, 9)
                stress = random.randint(2, 8)
                energy = random.randint(2, 8)
                sleep = round(random.uniform(5.0, 9.0), 1) if random.random() > 0.3 else None
                activity = random.randint(0, 60) if random.random() > 0.4 else None
                entry = models.MoodEntry(
                    mood=mood,
                    stress=stress,
                    energy=energy,
                    note=random.choice(NOTES),
                    category=random.choice(CATEGORIES),
                    sleep_hours=sleep,
                    activity_minutes=activity,
                    created_at=date.replace(
                        hour=random.randint(8, 20),
                        minute=random.randint(0, 59),
                        second=0,
                        microsecond=0,
                    ),
                )
                db.add(entry)
                added += 1
        db.commit()
        print(f"Added {added} mood entries for the past {DAYS_BACK} days.")
    finally:
        db.close()


if __name__ == "__main__":
    main()
