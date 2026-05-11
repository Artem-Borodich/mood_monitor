from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """App configuration from environment (optional `.env` in `backend/`)."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    database_url: str = (
        "postgresql+psycopg2://postgres:postgres@localhost:5432/mood_db"
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
