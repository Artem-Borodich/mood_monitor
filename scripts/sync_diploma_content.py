# -*- coding: utf-8 -*-
"""Текстовые блоки для синхронизации диплома с репозиторием."""
from __future__ import annotations


def n(text: str) -> tuple[str, str]:
    return ("Normal", text)


def code(text: str) -> tuple[str, str]:
    return ("Normal (Web)", text)


# --- Введение: замены по маркерам (скрипт подставит целиком абзацы) ---
INTRO_REPLACE_LOCAL_STORAGE = n(
    "При организации хранения данных журнал записей о настроении, стрессе и энергии "
    "размещается на сервере в СУБД PostgreSQL; мобильный клиент на фреймворке Флаттер "
    "обращается к серверу по программному интерфейсу. На устройстве пользователя "
    "сохраняются только параметры интерфейса и служебные отметки по советам "
    "(модуль locale_store.dart, встроенное хранилище ключей и значений), без "
    "дублирования журнала настроения локально."
)

SUBJECT_RESEARCH = n(
    "Предмет исследования: кроссплатформенное мобильное приложение для мониторинга "
    "психоэмоционального состояния с серверным хранением данных в PostgreSQL и "
    "клиентом на Флаттер."
)

SECTION_14_BLOCKS: list[tuple[str, str]] = [
    ("Heading 2", "1.4 Выбор средств для разработки клиентской части приложения"),
    n(
        "Клиентская часть реализована на Флаттер. Навигация построена вокруг "
        "корневого каркаса MainScaffold (файл main.dart): внизу три раздела — "
        "главная панель (DashboardScreen), история (HistoryScreen) и советы "
        "(RecommendationsScreen). Добавление полной записи выполняется не отдельной "
        "вкладкой, а через плавающую кнопку «+», открывающую полноэкранный поток "
        "AddMoodFlowPage с экраном AddMoodScreen. Настройки языка и темы доступны "
        "из иконки в верхней шапке и ведут на SettingsScreen."
    ),
    n(
        "Главная панель загружает с сервера список записей, индекс благополучия, "
        "прогноз, отображает график динамики, цель недели по числу дней с записями, "
        "ежедневный чек-ин, быстрый повтор последней записи и блок практик. История "
        "поддерживает список с фильтрами, календарное представление и режим аналитики. "
        "Экран советов сочетает персональную рекомендацию с сервера и локальный "
        "каталог статей из tips_data.dart с избранным и скрытием карточек."
    ),
    n(
        "Сетевой доступ инкапсулирован в ApiService; конфигурация адреса сервера — "
        "в AppConfig (для эмулятора Android используется адрес 10.0.2.2, для "
        "физического устройства — IP компьютера в Wi‑Fi, задаётся при сборке). "
        "Графики строятся библиотекой fl_chart."
    ),
]

SECTION_24_BLOCKS: list[tuple[str, str]] = [
    ("Heading 2", "2.4 Программная реализация интерфейса прикладного программирования"),
    n(
        "Серверная часть на FastAPI регистрирует маршруты из routes/mood.py и "
        "routes/diploma.py, проверку доступности GET /health в main.py и "
        "интерактивную документацию по адресу /docs. Ниже приведены фрагменты "
        "фактической реализации; имена функций и схем соответствуют репозиторию."
    ),
    n("Листинг 2.5 — создание записи (POST /mood), файл routes/mood.py."),
    code(
        '@router.post("/mood", response_model=schemas.MoodEntryRead, status_code=201)\n'
        "def create_mood_entry(payload: schemas.MoodEntryCreate, db: Session = Depends(get_db)):\n"
        "    db_entry = models.MoodEntry(...)\n"
        "    db.add(db_entry); db.commit(); db.refresh(db_entry)\n"
        "    return db_entry"
    ),
    n("Листинг 2.6 — список записей (GET /mood), сортировка по убыванию даты."),
    code(
        '@router.get("/mood", response_model=List[schemas.MoodEntryRead])\n'
        "def list_mood_entries(db: Session = Depends(get_db)):\n"
        "    return db.query(models.MoodEntry).order_by(desc(models.MoodEntry.created_at)).all()"
    ),
    n("Листинг 2.7 — изменение записи (PUT /mood/{entry_id})."),
    code(
        '@router.put("/mood/{entry_id}", response_model=schemas.MoodEntryRead)\n'
        "def update_mood_entry(entry_id: int, payload: schemas.MoodEntryCreate, ...):\n"
        "    ...  # обновление полей; db.commit(); db.refresh(entry)"
    ),
    n("Листинг 2.8 — удаление записи (DELETE /mood/{entry_id}), ответ 204 без тела."),
    code(
        '@router.delete("/mood/{entry_id}", status_code=204)\n'
        "def delete_mood_entry(entry_id: int, db: Session = Depends(get_db)):\n"
        "    ...\n"
        "    db.delete(entry); db.commit()\n"
        "    return None"
    ),
    n("Листинг 2.9 — индекс благополучия (GET /wellbeing)."),
    code(
        '@router.get("/wellbeing", response_model=schemas.WellbeingResponse)\n'
        "def get_current_wellbeing(db: Session = Depends(get_db)):\n"
        "    last_entry = db.query(models.MoodEntry).order_by(desc(...)).first()\n"
        "    return build_wellbeing_response(last_entry)"
    ),
    n("Листинг 2.10 — рекомендация (GET /recommendations?lang=)."),
    code(
        '@router.get("/recommendations", response_model=schemas.RecommendationResponse)\n'
        "def get_recommendations(lang: str = Query(\"en\"), db: Session = Depends(get_db)):\n"
        "    return build_recommendation_response(last_entry, lang)"
    ),
    n("Листинг 2.11 — прогноз (GET /forecast), routes/diploma.py."),
    code(
        '@router.get("/forecast", response_model=schemas.ForecastRead)\n'
        "def get_forecast(user_id: int = 1, lang: str = \"en\", db: Session = Depends(get_db)):\n"
        "    entries = _entries_for_forecast(db)  # до 14 последних\n"
        "    return forecast_from_entries(entries, lang)"
    ),
    n("Листинг 2.12 — приём отзыва (POST /feedback), без сохранения в БД."),
    code(
        '@router.post("/feedback", status_code=201)\n'
        "def post_feedback(payload: schemas.FeedbackCreate):\n"
        '    return {"status": "received"}'
    ),
    n("Листинг 2.13 — проверка доступности (GET /health), main.py."),
    code('@app.get("/health")\ndef health():\n    return {"status": "ok", "service": "wellbeing-api"}'),
    n("Листинг 2.14 — подключение к PostgreSQL, database.py и config/settings.py."),
    code(
        "# config/settings.py — строка database_url, переопределение через .env\n"
        '# database.py\n'
        "engine = create_engine(_settings.database_url, future=True)\n"
        "SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)"
    ),
    n(
        "Клиент (ApiService) вызывает перечисленные адреса; при удалении ожидается "
        "код 204; при создании — 201. Валидация тел запросов выполняется схемами "
        "Pydantic в schemas.py."
    ),
]

SECTION_25_BLOCKS: list[tuple[str, str]] = [
    ("Heading 2", "2.5 Серверная аналитика и алгоритмы"),
    ("Heading 3", "2.5.1 Индекс благополучия"),
    n(
        "В wellbeing_constants.py зафиксированы веса: настроение 0,4, энергия 0,3, "
        "стресс 0,3. В wellbeing_service.py индекс вычисляется как линейная комбинация "
        "и округляется до двух знаков: индекс = 0,4·настроение + 0,3·энергия − 0,3·стресс. "
        "Эндпоинт /wellbeing возвращает значение по последней записи в журнале и её "
        "идентификатор (поля wellbeing_index и based_on_entry_id)."
    ),
    ("Heading 3", "2.5.2 Рекомендации"),
    n(
        "Модуль recommendation_service.py после расчёта индекса применяет правила к "
        "последней записи: высокий стресс при недостатке сна; стресс при категории "
        "«работа»; низкая энергия без активности; пороги индекса для уровней низкий, "
        "средний и высокий. Текст формируется на русском или английском по параметру "
        "lang. При отсутствии записей уровень none и сообщение о необходимости первой "
        "отметки."
    ),
    ("Heading 3", "2.5.3 Прогноз на следующий день"),
    n(
        "Модуль forecast_service.py получает до 14 последних записей (запрос в "
        "diploma.py). Константа MIN_ENTRIES_FOR_FORECAST = 3: при нуле, одной или "
        "двух записях статус insufficient_data, в ответе entries_used равно фактическому "
        "числу записей и текстовое пояснение. При трёх и более записях вычисляется риск "
        "по средним настроению и стрессу, компоненту сна (целевое значение 6,5 ч), "
        "штрафу за падение настроения во второй половине окна (при шести и более точках). "
        "Коэффициенты: стресс 0,38, настроение 0,28, сон 0,22; риск ограничен диапазоном "
        "0,05–0,92. В ответе также label, factors, explanation, target_date и entries_used."
    ),
    n(
        "Вывод по §2.5. Аналитика сосредоточена на сервере; клиент отображает готовые "
        "числа и тексты, что исключает расхождение формул на устройстве."
    ),
]

SECTION_3_BLOCKS: list[tuple[str, str]] = [
    ("Heading 1", "3 Интерфейс и возможности приложения"),
    n(
        "В разделе описано фактическое поведение клиента после подключения к PostgreSQL "
        "и запуска сервера FastAPI. Описание опирается на исходный код экранов; "
        "скриншоты размещаются по подписям рисунков 3.1–3.17 в соответствующих подпунктах."
    ),
    ("Heading 2", "3.1 Главная панель"),
    n(
        "DashboardScreen при открытии запрашивает список записей, индекс благополучия "
        "и прогноз (с учётом языка интерфейса). При отсутствии записей показывается "
        "пустое состояние с предложением добавить первую отметку. При наличии данных "
        "отображаются приветственный блок DashboardHero, цель недели "
        "(DashboardWeeklyLoggingGoal — число дней с записями за текущую неделю с "
        "понедельника по воскресенье), краткий текстовый инсайт по сравнению с "
        "предыдущей записью, сводка практик DashboardPracticesSummary с серией дней "
        "выполнения быстрых действий, ежедневный чек-ин DashboardDailyCheckIn "
        "(быстрая оценка настроения с сохранением на сервер), карточка быстрого ввода "
        "DashboardQuickLogCard и нижний лист QuickLogBottomSheet для повтора последних "
        "значений, карточка индекса DashboardWellbeingCard, график DashboardTrendChart, "
        "карусель советов DashboardTipsScroller и карточка прогноза DashboardRiskCard "
        "с пояснением при недостаточном числе записей (менее трёх). После сохранения "
        "записи через FAB срабатывает перезагрузка по dashboardReloadTick."
    ),
    ("Heading 2", "3.2 История записей"),
    n(
        "HistoryScreen загружает полный список с сервера и поддерживает три режима "
        "(_viewMode): список, календарь MoodCalendarHeatmap (цвет по максимальному "
        "настроению за день, выбор дня фильтрует список), аналитика с графиками "
        "настроение–стресс, настроение–сон и недельный обзор (fl_chart). Доступны "
        "фильтры по диапазону дат, категории и шкалам. Редактирование выполняется на "
        "EditMoodScreen с вызовом PUT /mood/{id}. Обновление списка — жестом обновления."
    ),
    ("Heading 2", "3.3 Добавление и редактирование записи"),
    n(
        "AddMoodScreen (в потоке AddMoodFlowPage) задаёт обязательные шкалы настроения, "
        "стресса и энергии (1–10), опционально категорию, часы сна, минуты активности, "
        "заметку и дату. Отправка — POST /mood через ApiService. Поля соответствуют "
        "схеме MoodEntryCreate на сервере."
    ),
    ("Heading 2", "3.4 Советы и рекомендации"),
    n(
        "RecommendationsScreen в верхней части показывает ответ GET /recommendations "
        "(текст и уровень). Ниже — локальный каталог Tip из tips_data.dart с фильтром "
        "по категории, избранным, скрытием карточек, отметками полезно/неполезно "
        "(SharedPreferences через locale_store). Доступны экран деталей совета, "
        "дыхательный таймер BreathingTimerScreen, быстрые отметки «дыхание» и «прогулка» "
        "за день. Отзыв может быть отправлен POST /feedback без хранения в базе."
    ),
    ("Heading 2", "3.5 Настройки и подключение к серверу"),
    n(
        "SettingsScreen открывается из шапки приложения. Пользователь выбирает язык "
        "(русский/английский) и тему (светлая, тёмная, системная), значения сохраняются "
        "локально. На экране отображаются версия приложения, текущий базовый URL API "
        "(AppConfig.apiBaseUrl) и пояснение для отладки в Wi‑Fi. Проверка связи "
        "реализована в ApiService.pingHealth() к GET /health."
    ),
    ("Heading 2", "3.6 Обработка ошибок"),
    n(
        "При сбое сети или таймауте (25 с) ApiService генерирует исключение, "
        "пользователю показывается сообщение через AppErrorView или SerenityMessenger; "
        "тексты ошибок сервера могут локализоваться api_message_localizer. Локальные "
        "настройки и избранные советы остаются доступны без сервера; новые записи "
        "журнала без сервера не создаются."
    ),
    n(
        "Вывод по главе 3. Интерфейс согласован с требованиями §1.3 и реализацией "
        "серверного API: навигация, аналитика и советы разделены между сетевыми "
        "запросами и локальным хранилищем параметров."
    ),
]

CONCLUSION_REPLACE = n(
    "В разработанном приложении журнал настроения, стресса и энергии хранится в "
    "PostgreSQL; мобильный клиент на Флаттер получает и изменяет данные через "
    "программный интерфейс FastAPI. На устройстве локально сохраняются язык, тема и "
    "метаданные по советам. Реализованы индекс благополучия, персональные рекомендации "
    "и прогноз на сервере, главная панель с целью недели и прогнозом, история с "
    "календарём и аналитикой, каталог советов и настройки подключения к серверу."
)
