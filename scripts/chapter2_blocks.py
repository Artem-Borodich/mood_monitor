# -*- coding: utf-8 -*-
"""Content blocks for chapter 2.1–2.3 (style, text) and diagram paths."""
from __future__ import annotations

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIAGRAMS = os.path.join(ROOT, "docs", "diagrams")

# Block types: ("style", text) | ("image", path) | ("caption", text)
CHAPTER2_BLOCKS: list[tuple[str, str]] = [
    ("Heading 2", "2.1 Архитектура системы"),
    ("Heading 3", "2.1.1 Общая клиент-серверная схема"),
    (
        "Normal",
        "Разрабатываемая система мониторинга психоэмоционального состояния построена по классической "
        "трёхуровневой схеме «клиент — сервер приложений — сервер данных». Пользователь взаимодействует "
        "с кроссплатформенным мобильным клиентом на Flutter (пользовательское имя продукта — Serenity, "
        "репозиторий — Mood Monitor). Клиент обращается к REST API, реализованному на FastAPI; серверная "
        "логика обрабатывает запросы, выполняет валидацию и обращается к реляционной СУБД PostgreSQL "
        "через ORM SQLAlchemy.",
    ),
    (
        "Normal",
        "Такое разделение обеспечивает единый источник истины для журнала настроения: все записи о mood, "
        "stress и energy хранятся в таблице mood_entries на сервере. Клиент не использует локальную СУБД "
        "(в том числе SQLite) для журнала; на устройстве сохраняются только параметры интерфейса и "
        "метаданные по советам (SharedPreferences, модуль locale_store.dart). Расчёт индекса "
        "благополучия, текстов рекомендаций и краткосрочного прогноза выполняется на сервере в модулях "
        "services/, что соответствует требованиям §1.3.",
    ),
    (
        "Normal",
        "Связь уровней осуществляется по HTTP; полезная нагрузка запросов и ответов — JSON. Для учебного "
        "развёртывания допускается работа в локальной сети (API_BASE_URL через dart-define при запуске на "
        "физическом устройстве); аутентификация в текущей версии не реализована.",
    ),
    ("Heading 3", "2.1.2 Серверная часть (FastAPI)"),
    (
        "Normal",
        "Точка входа сервера — файл main.py. При старте создаётся экземпляр FastAPI, подключается "
        "middleware CORS, регистрируются маршруты из routes/mood.py и routes/diploma.py, вызывается "
        "Base.metadata.create_all для создания таблиц в PostgreSQL. Служебный эндпоинт GET /health "
        "возвращает статус доступности сервиса.",
    ),
    (
        "Normal",
        "Модуль database.py задаёт подключение к PostgreSQL: строка database_url считывается из "
        "config/settings.py (по умолчанию postgresql+psycopg2://…/mood_db, переопределение через .env). "
        "Создаются engine, SessionLocal и генератор get_db(), выдающий сессию на время запроса.",
    ),
    (
        "Normal",
        "Пакет models/ содержит класс MoodEntry (models.py), отображаемый на таблицу mood_entries. "
        "Пакет schemas/ описывает контракты Pydantic: MoodEntryCreate, MoodEntryRead, WellbeingResponse, "
        "RecommendationResponse, ForecastRead, FeedbackCreate. Пакет routes/ реализует HTTP-слой: mood.py — "
        "CRUD /mood, /wellbeing, /recommendations; diploma.py — /forecast и /feedback. Пакет services/ "
        "содержит wellbeing_service.py, recommendation_service.py и forecast_service.py с бизнес-правилами.",
    ),
    ("Heading 3", "2.1.3 Клиентская часть (Flutter)"),
    (
        "Normal",
        "Клиент расположен в каталоге flutter_app/lib/. Точка входа — main.dart: загрузка языка и темы из "
        "locale_store.dart, MaterialApp и MainScaffold с нижней навигацией. Экраны screens/ — "
        "dashboard_screen.dart, history_screen.dart, recommendations_screen.dart, settings_screen.dart, "
        "add_mood_screen.dart, edit_mood_screen.dart и др. Сетевой слой — services/api_service.dart; "
        "модели ответов — models/mood_entry.dart, forecast_payload.dart. Базовый URL — core/app_config.dart.",
    ),
    ("Heading 3", "2.1.4 Обмен данными по REST и JSON"),
    (
        "Normal",
        "Взаимодействие соответствует REST: ресурс записи — /mood и /mood/{entry_id}; агрегаты — /wellbeing, "
        "/recommendations, /forecast. ApiService формирует URI, заголовок Content-Type: application/json, "
        "кодирует тело через jsonEncode и разбирает ответы; таймаут — 25 с. Ошибки преобразуются в "
        "ApiException для отображения пользователю.",
    ),
    ("Heading 3", "2.1.5 Локальное хранилище (SharedPreferences)"),
    (
        "Normal",
        "Модуль locale_store.dart хранит язык (app_locale), тему (app_theme_mode), идентификаторы "
        "избранных и скрытых советов, отметки полезности и выполненные действия за день. Журнал настроения "
        "на сервере не дублируется локально.",
    ),
    ("Heading 3", "2.1.6 Поток данных при создании записи"),
    (
        "Normal",
        "Пользователь вводит данные на AddMoodScreen → ApiService.createMoodEntry → POST /mood → "
        "валидация MoodEntryCreate → models.MoodEntry → db.add, commit, refresh → ответ 201 → обновление "
        "Dashboard (повторные GET /mood, /wellbeing, /forecast).",
    ),
    (
        "Normal",
        "Вывод по §2.1. Архитектура построена как клиент-серверное приложение с централизованным "
        "хранением журнала в PostgreSQL и серверной аналитикой в services/.",
    ),
    ("Heading 2", "2.2 Модель данных и база данных"),
    ("Heading 3", "2.2.1 СУБД PostgreSQL"),
    (
        "Normal",
        "Выбрана СУБД PostgreSQL с поддержкой транзакций ACID и типов даты-времени с часовым поясом. "
        "Подключение задаётся в config/settings.py; драйвер psycopg2 используется через SQLAlchemy.",
    ),
    ("Heading 3", "2.2.2 Таблица mood_entries"),
    (
        "Normal",
        "Поле id — первичный ключ. Поля mood, stress, energy — обязательные целые 1–10. Поле note — "
        "текстовая заметка (TEXT, nullable). Поле category — тег до 50 символов (nullable, индекс). "
        "Поле sleep_hours — часы сна 0–24 (nullable). Поле activity_minutes — минуты активности 0–1440 "
        "(nullable). Поле created_at — метка времени с TZ, NOT NULL, сортировка по убыванию.",
    ),
    ("Heading 3", "2.2.3 SQLAlchemy ORM и database.py"),
    (
        "Normal",
        "Класс MoodEntry наследует Base; сессия SessionLocal накапливает изменения и фиксирует commit(). "
        "Схемы Pydantic отделены от ORM: MoodEntryCreate на вход, MoodEntryRead на выход с from_attributes.",
    ),
    ("Heading 3", "2.2.4 Жизненный цикл записи"),
    (
        "Normal",
        "Создание: add, commit, refresh в create_mood_entry. Чтение: query с order_by(desc(created_at)). "
        "Обновление: присвоение полей и commit в update_mood_entry. Удаление: delete и commit, ответ 204. "
        "Для прогноза diploma.py выбирает до 14 последних записей.",
    ),
    ("Heading 3", "2.2.5 ER-модель"),
    (
        "Normal",
        "Логическая модель включает одну сущность «Запись настроения» (mood_entries) без связей с другими "
        "таблицами в текущей версии. ER-диаграмма представлена на рисунке 2.1.",
    ),
    ("image", os.path.join(DIAGRAMS, "er_mood_entries.png")),
    (
        "caption",
        "Рисунок 2.1 — Логическая ER-модель (сущность mood_entries)",
    ),
    (
        "Normal",
        "Вывод по §2.2. Модель данных минимальна и покрывает весь журнал мониторинга; операции ORM "
        "согласованы с REST API и ApiService.",
    ),
    ("Heading 2", "2.3 UML-моделирование системы"),
    ("Heading 3", "2.3.1 Диаграмма вариантов использования"),
    (
        "Normal",
        "Актор «Пользователь» взаимодействует с системой Mood Monitor (Serenity): создание, просмотр, "
        "изменение и удаление записей (UC-01–UC-04), настройки (UC-08), отзыв о совете (UC-09). "
        "Серверные варианты UC-05–UC-07 связаны с /wellbeing, /recommendations и /forecast. "
        "Диаграмма приведена на рисунке 2.2.",
    ),
    ("image", os.path.join(DIAGRAMS, "use_case.png")),
    ("caption", "Рисунок 2.2 — Диаграмма вариантов использования"),
    ("Heading 3", "2.3.2 Диаграмма последовательности"),
    (
        "Normal",
        "На рисунке 2.3 показан синхронный сценарий POST /mood: AddMoodScreen → ApiService → "
        "routes/mood.py → SQLAlchemy → PostgreSQL → ответ 201 и обновление интерфейса.",
    ),
    ("image", os.path.join(DIAGRAMS, "sequence_create_mood.png")),
    (
        "caption",
        "Рисунок 2.3 — Диаграмма последовательности: создание записи настроения",
    ),
    ("Heading 3", "2.3.3 Диаграмма компонентов"),
    (
        "Normal",
        "Компоненты Flutter (экраны, ApiService, locale_store, models) связаны по HTTP с FastAPI "
        "(routes, services, schemas, database.py) и PostgreSQL. Диаграмма компонентов — рисунок 2.4.",
    ),
    ("image", os.path.join(DIAGRAMS, "components.png")),
    ("caption", "Рисунок 2.4 — Диаграмма компонентов системы"),
    (
        "Normal",
        "Вывод по §2.3. UML-диаграммы согласованы с реализацией в репозитории и требованиями §1.3; "
        "рисунки 2.1–2.4 отражают данные, поведение и размещение модулей.",
    ),
    ("Heading 2", "2.4 Программная реализация REST API"),
]
