"""
Migration: add category, sleep_hours, activity_minutes to mood_entries.
Run once: python migrate_add_columns.py
"""
import os
import sys

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from database import engine

MIGRATIONS = [
    "ALTER TABLE mood_entries ADD COLUMN IF NOT EXISTS category VARCHAR(50);",
    "ALTER TABLE mood_entries ADD COLUMN IF NOT EXISTS sleep_hours DOUBLE PRECISION;",
    "ALTER TABLE mood_entries ADD COLUMN IF NOT EXISTS activity_minutes INTEGER;",
]


def main():
    print("Running migration: add category, sleep_hours, activity_minutes...")
    with engine.connect() as conn:
        for sql in MIGRATIONS:
            try:
                conn.execute(text(sql))
                conn.commit()
                print(f"  OK: {sql[:60]}...")
            except Exception as e:
                print(f"  Skip/Error: {e}")
    print("Migration complete.")


if __name__ == "__main__":
    main()
