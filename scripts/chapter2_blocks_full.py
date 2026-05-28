# -*- coding: utf-8 -*-
"""Full-length §2.1–2.3 blocks (~10 pages)."""
from __future__ import annotations

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIAGRAMS = os.path.join(ROOT, "docs", "diagrams")

# Loaded by insert_chapter2 when --full flag is used
CHAPTER2_BLOCKS: list[tuple[str, str]] = []

def _p(text: str) -> tuple[str, str]:
    return ("Normal", text)


def build_blocks() -> list[tuple[str, str]]:
    blocks: list[tuple[str, str]] = [
        ("Heading 2", "2.1 Архитектура системы"),
        ("Heading 3", "2.1.1 Общая клиент-серверная схема"),
        _p(
            "Разрабатываемая система мониторинга психоэмоционального состояния построена по "
            "классической трёхуровневой схеме «клиент — сервер приложений — сервер данных». "
            "Пользователь взаимодействует с кроссплатформенным мобильным клиентом на Flutter "
            "(пользовательское имя продукта — Serenity, репозиторий — Mood Monitor). Клиент "
            "обращается к REST API, реализованному на FastAPI; серверная логика обрабатывает "
            "запросы, выполняет валидацию и обращается к реляционной СУБД PostgreSQL через ORM "
            "SQLAlchemy."
        ),
        _p(
            "Такое разделение обеспечивает единый источник истины для журнала настроения: все "
            "записи о mood, stress и energy хранятся в таблице mood_entries на сервере. Клиент "
            "не использует локальную СУБД (в том числе SQLite) для журнала; на устройстве "
            "сохраняются только параметры интерфейса и метаданные по советам (SharedPreferences, "
            "модуль locale_store.dart). Расчёт индекса благополучия, текстов рекомендаций и "
            "краткосрочного прогноза выполняется на сервере в модулях services/, что соответствует "
            "требованиям §1.3 и исключает расхождение формул между платформами."
        ),
        _p(
            "Связь уровней осуществляется по HTTP; полезная нагрузка запросов и ответов — JSON. "
            "Для учебного развёртывания допускается работа в локальной сети (например, "
            "API_BASE_URL через dart-define при запуске на физическом устройстве); аутентификация "
            "в текущей версии не реализована, параметр user_id на клиенте передаётся для "
            "совместимости с контрактом API."
        ),
        ("Heading 3", "2.1.2 Серверная часть (FastAPI)"),
        _p(
            "Точка входа сервера — файл main.py. При старте создаётся экземпляр FastAPI, "
            "подключается middleware CORS (разрешены кросс-доменные запросы для отладки), "
            "регистрируются маршруты из пакетов routes/mood.py и routes/diploma.py, вызывается "
            "Base.metadata.create_all для создания таблиц в PostgreSQL. Служебный эндпоинт "
            "GET /health возвращает статус доступности сервиса."
        ),
        _p(
            "Структура каталога backend организована по слоям ответственности. Модуль database.py "
            "задаёт подключение к PostgreSQL: строка database_url считывается из config/settings.py "
            "(значение по умолчанию — postgresql+psycopg2://postgres:postgres@localhost:5432/mood_db, "
            "переопределение через файл .env). Создаются engine, фабрика сессий SessionLocal и "
            "генератор зависимости get_db(), который выдаёт сессию на время обработки запроса и "
            "гарантированно закрывает её в блоке finally."
        ),
        _p(
            "Пакет models/ содержит декларативные модели SQLAlchemy. Класс MoodEntry (models.py) "
            "отображается на таблицу mood_entries; это единственная сущность предметной области в "
            "текущей схеме БД. Пакет schemas/ описывает контракты Pydantic: MoodEntryCreate и "
            "MoodEntryRead для CRUD, WellbeingResponse и RecommendationResponse для аналитики, "
            "ForecastRead для прогноза, FeedbackCreate для приёма отзыва."
        ),
        _p(
            "Пакет routes/ реализует тонкий HTTP-слой. В mood.py сосредоточены операции с журналом "
            "(POST, GET, PUT, DELETE /mood), а также GET /wellbeing и GET /recommendations — "
            "последние делегируют расчёты в services/recommendation_service.py. В diploma.py — "
            "GET /forecast (вызов services/forecast_service.py) и POST /feedback (приём без "
            "обязательного сохранения в БД)."
        ),
        _p(
            "Пакет services/ содержит бизнес-логику. Модуль wellbeing_service.py вычисляет "
            "линейный индекс по весам из wellbeing_constants.py (MOOD_WEIGHT = 0,4, "
            "ENERGY_WEIGHT = 0,3, STRESS_WEIGHT = 0,3). recommendation_service.py формирует "
            "уровень и текст рекомендации по последней записи. forecast_service.py строит прогноз "
            "риска на следующий день по окну до 14 последних записей; MIN_ENTRIES_FOR_FORECAST = 3 "
            "задаёт порог достаточности данных."
        ),
        ("Heading 3", "2.1.3 Клиентская часть (Flutter)"),
        _p(
            "Клиент расположен в каталоге flutter_app/lib/. Точка входа — main.dart: инициализация "
            "локализации дат, загрузка сохранённых языка и темы из locale_store.dart, построение "
            "MaterialApp и корневого MainScaffold с нижней навигацией."
        ),
        _p(
            "Экраны (screens/) реализуют пользовательские сценарии: dashboard_screen.dart — главная "
            "панель; add_mood_screen.dart и add_mood_flow_page.dart — создание записи; "
            "edit_mood_screen.dart — редактирование; history_screen.dart — список, календарь "
            "(mood_calendar_heatmap.dart), аналитика; recommendations_screen.dart — советы; "
            "settings_screen.dart — язык и тема; breathing_timer_screen.dart — дыхательная практика."
        ),
        _p(
            "Модели (models/) — mood_entry.dart, forecast_payload.dart. Сервисы (services/) — "
            "api_service.dart, api_exception.dart. Виджеты (widgets/) — карточки дашборда и истории. "
            "Прочие модули: core/app_config.dart, l10n/app_localizations.dart, data/tips_data.dart, "
            "design_system/ и theme/ — оформление в духе Material Design."
        ),
        ("Heading 3", "2.1.4 Обмен данными по REST и JSON"),
        _p(
            "Взаимодействие клиента и сервера соответствует стилю REST: ресурс «запись настроения» "
            "идентифицируется путём /mood и /mood/{entry_id}; агрегированные показатели — "
            "отдельными ресурсами /wellbeing, /recommendations, /forecast."
        ),
        _p(
            "Класс ApiService инкапсулирует формирование URI (база из AppConfig.apiBaseUrl), "
            "заголовок Content-Type: application/json, кодирование тела через jsonEncode и разбор "
            "ответов через jsonDecode. Таймаут запросов — 25 секунд; метод проверки связи "
            "обращается к GET /health с укороченным таймаутом. Ошибки сети и коды 4xx/5xx "
            "преобразуются в ApiException."
        ),
        ("Heading 3", "2.1.5 Локальное хранилище настроек (SharedPreferences)"),
        _p(
            "Модуль locale_store.dart обращается к SharedPreferences и хранит ключи: app_locale, "
            "app_theme_mode, saved_tip_ids, dismissed_tip_ids, helpful_tip_ids, not_helpful_tip_ids, "
            "а также префикс completed_actions_ с датой. Эти данные не дублируются на сервере."
        ),
        ("Heading 3", "2.1.6 Поток данных при создании записи настроения"),
        _p(
            "1) Пользователь на экране Add Mood задаёт значения шкал. 2) Вызывается "
            "ApiService.createMoodEntry, выполняется POST /mood. 3) FastAPI валидирует "
            "MoodEntryCreate, создаёт models.MoodEntry, db.add, commit, refresh. 4) PostgreSQL "
            "сохраняет строку; сервер возвращает MoodEntryRead. 5) Клиент обновляет UI; при "
            "возврате на Dashboard — повторная загрузка списка и прогноза."
        ),
        _p(
            "Вывод по §2.1. Архитектура системы построена как клиент-серверное приложение с "
            "централизованным хранением журнала в PostgreSQL и вынесенной на сервер "
            "бизнес-логикой аналитики."
        ),
        ("Heading 2", "2.2 Модель данных и база данных"),
        ("Heading 3", "2.2.1 СУБД PostgreSQL"),
        _p(
            "В качестве СУБД выбран PostgreSQL — система с поддержкой транзакций ACID, типов даты "
            "и времени с часовым поясом и надёжного хранения при одновременных сессиях. Для "
            "учебного проекта PostgreSQL предпочтительнее SQLite: сервер и БД могут работать на "
            "отдельном хосте, что соответствует схеме развёртывания мобильного клиента в Wi‑Fi-сети."
        ),
        ("Heading 3", "2.2.2 Таблица mood_entries и назначение полей"),
        _p(
            "Единственная предметная таблица — mood_entries. Поле id — первичный ключ. Поля mood, "
            "stress, energy — обязательные целые 1–10. Поле note — текстовая заметка (TEXT, nullable). "
            "Поле category — тег до 50 символов (nullable, индекс). Поле sleep_hours — часы сна "
            "0–24 (nullable). Поле activity_minutes — минуты активности 0–1440 (nullable). "
            "Поле created_at — метка времени с TZ, NOT NULL, сортировка по убыванию."
        ),
        ("Heading 3", "2.2.3 SQLAlchemy ORM и модуль database.py"),
        _p(
            "SQLAlchemy реализует объектно-реляционное отображение: класс MoodEntry наследует Base. "
            "Зависимость get_db() создаёт сессию на каждый запрос. Схемы Pydantic отделены от ORM."
        ),
        ("Heading 3", "2.2.4 Жизненный цикл записи"),
        _p(
            "Создание: add, commit, refresh. Чтение: query с order_by(desc(created_at)). Обновление: "
            "присвоение полей и commit. Удаление: delete, commit, код 204. Для /forecast выбирается "
            "до 14 последних записей."
        ),
        ("Heading 3", "2.2.5 ER-модель"),
        _p(
            "На рисунке 2.1 изображена сущность «Запись настроения» с атрибутами Id (PK), Mood, "
            "Stress, Energy, Note, Category, SleepHours, ActivityMinutes, CreatedAt. Связей с другими "
            "таблицами в текущей версии нет."
        ),
        ("image", os.path.join(DIAGRAMS, "er_mood_entries.png")),
        ("caption", "Рисунок 2.1 — Логическая ER-модель (сущность mood_entries)"),
        _p(
            "Вывод по §2.2. Модель данных минимальна: одна таблица mood_entries покрывает весь журнал; "
            "операции ORM согласованы с REST API."
        ),
        ("Heading 2", "2.3 UML-моделирование системы"),
        ("Heading 3", "2.3.1 Диаграмма вариантов использования"),
        _p(
            "Актор «Пользователь» взаимодействует с системой Mood Monitor (Serenity): UC-01–UC-04 "
            "(журнал), UC-08 (настройки), UC-09 (отзыв). Варианты UC-05–UC-07 соответствуют "
            "серверным GET /wellbeing, /recommendations, /forecast. Диаграмма — рисунок 2.2."
        ),
        ("image", os.path.join(DIAGRAMS, "use_case.png")),
        ("caption", "Рисунок 2.2 — Диаграмма вариантов использования"),
        ("Heading 3", "2.3.2 Диаграмма последовательности"),
        _p(
            "Участники: Пользователь, AddMoodScreen, ApiService, routes/mood.py, SQLAlchemy Session, "
            "PostgreSQL. Сообщения: ввод данных → POST /mood → INSERT → 201 → обновление UI. "
            "Диаграмма — рисунок 2.3."
        ),
        ("image", os.path.join(DIAGRAMS, "sequence_create_mood.png")),
        ("caption", "Рисунок 2.3 — Диаграмма последовательности: создание записи настроения"),
        ("Heading 3", "2.3.3 Диаграмма компонентов"),
        _p(
            "Узел Flutter: UI Screens, ApiService, locale_store, models, tips_data. Узел Python: "
            "FastAPI, routes, services, schemas, database.py. Узел PostgreSQL: mood_entries. "
            "Диаграмма — рисунок 2.4."
        ),
        ("image", os.path.join(DIAGRAMS, "components.png")),
        ("caption", "Рисунок 2.4 — Диаграмма компонентов системы"),
        _p(
            "Вывод по §2.3. UML-диаграммы согласованы с реализацией в репозитории и требованиями §1.3."
        ),
        ("Heading 2", "2.4 Программная реализация REST API"),
    ]
    return blocks


CHAPTER2_BLOCKS = build_blocks()
