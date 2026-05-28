# -*- coding: utf-8 -*-
"""Список литературы и соответствие ключевых слов ссылкам [N]."""
from __future__ import annotations

# Нумерованный список (устаревший формат).
BIBLIOGRAPHY: list[str] = [
    "Наполитано С. Flutter для начинающих: введение в разработку кроссплатформенных мобильных приложений с использованием Flutter и Dart. – 2-е изд. – Бирмингем: Packt Publishing, 2021. – 370 с.",
    "Бейли Т. Flutter и Dart: рецепты разработки полностековых приложений для облака. – Себастопол: O'Reilly Media, 2023. – 350 с.",
    "Лутц М. Изучаем Python / Марк Лутц; [пер. с англ. А. Киселева]. – 5-е изд. – М. : Диалектика, 2019. – 832 с. : ил.",
    "Рамирес А. FastAPI: современная веб-разработка на Python / А. Рамирес. – Себастопол: O'Reilly Media, 2024. – 300 с.",
    "Коупленд Р. SQLAlchemy: доступ к базам данных с использованием Python / Р. Коупленд. – Себастопол: O'Reilly Media, 2019. – 250 с.",
    "Документация Flutter [Электронный ресурс]. – Режим доступа: https://docs.flutter.dev/. – Дата доступа: 10.02.2026.",
    "Документация FastAPI [Электронный ресурс]. – Режим доступа: https://fastapi.tiangolo.com/. – Дата доступа: 15.02.2026.",
    "Руководство по Material Design [Электронный ресурс]. – Режим доступа: https://m3.material.io/. – Дата доступа: 20.02.2026.",
    "PostgreSQL 15 Documentation [Электронный ресурс]. – Режим доступа: https://www.postgresql.org/docs/15/. – Дата доступа: 01.03.2026.",
    "Филдинг Р. Архитектурные стили и проектирование сетевых программных архитектур: дис. … докт. техн. наук / Р. Т. Филдинг. – 2000. – 180 с.",
    "Ричардсон Л. RESTful Web APIs / Л. Ричардсон, М. Амиундсен, С. Рубио. – Себастопол: O'Reilly Media, 2013. – 408 с.",
    "Таненбаум Э. Компьютерные сети / Э. Таненбаум, Д. Уэзеролл. – 6-е изд. – СПб. : Питер, 2021. – 912 с.",
    "Голицын А. Мобильная разработка: Android, iOS, Flutter / А. Голицын. – М. : ДМК Пресс, 2022. – 320 с.",
    "Соммер Р. Клиент-серверные системы: проектирование и реализация / Р. Соммер. – М. : Диалектика, 2018. – 384 с.",
    "Платонов С. Психодиагностика: учеб. пособие / С. Платонов. – СПб. : Речь, 2017. – 352 с.",
    "Королев И. Мониторинг эмоционального состояния с использованием мобильных приложений / И. Королев // Программные продукты и системы. – 2020. – № 2. – С. 301–308.",
    "Документация SQLAlchemy [Электронный ресурс]. – Режим доступа: https://docs.sqlalchemy.org/. – Дата доступа: 05.03.2026.",
    "Документация Pydantic [Электронный ресурс]. – Режим доступа: https://docs.pydantic.dev/. – Дата доступа: 05.03.2026.",
    "Гамма Э. Приёмы объектно-ориентированного проектирования / Э. Гамма, Р. Хелм, Р. Джонсон, Д. Влиссидес. – СПб. : Питер, 2020. – 368 с.",
    "Мартин Р. Чистая архитектура. Искусство разработки программного обеспечения / Р. Мартин. – СПб. : Питер, 2018. – 352 с.",
]

# Формат как в примере (Author, Title : monogr. / … – Place : Publisher, year. – N p.)
BIBLIOGRAPHY_MONOGR: list[str] = [
    "Napolitano, S. Flutter для начинающих: введение в разработку кроссплатформенных мобильных приложений : monogr. / S. Napolitano. – Birmingham : Packt Publishing, 2021. – 370 p.",
    "Bailey, T. Flutter и Dart: рецепты разработки полностековых приложений : monogr. / T. Bailey. – Sebastopol : O'Reilly Media, 2023. – 350 p.",
    "Lutz, M. Изучаем Python : monogr. / M. Lutz; [пер. с англ. A. Kiselev]. – 5th ed. – Moscow : DiaSoft, 2019. – 832 p.",
    "Ramirez, A. FastAPI: современная веб-разработка на Python : monogr. / A. Ramirez. – Sebastopol : O'Reilly Media, 2024. – 300 p.",
    "Copeland, R. SQLAlchemy: доступ к базам данных с использованием Python : monogr. / R. Copeland. – Sebastopol : O'Reilly Media, 2019. – 250 p.",
    "Flutter SDK Documentation : [site]. – URL: https://docs.flutter.dev/ (date of access: 10.02.2026).",
    "FastAPI Documentation : [site]. – URL: https://fastapi.tiangolo.com/ (date of access: 15.02.2026).",
    "Material Design 3 Guidelines : [site]. – URL: https://m3.material.io/ (date of access: 20.02.2026).",
    "PostgreSQL 15 Documentation : [site]. – URL: https://www.postgresql.org/docs/15/ (date of access: 01.03.2026).",
    "Fielding, R. T. Architectural Styles and the Design of Network-based Software Architectures : diss. / R. T. Fielding. – 2000. – 180 p.",
    "Richardson, L. RESTful Web APIs : monogr. / L. Richardson, M. Amundsen, S. Ruby. – Sebastopol : O'Reilly Media, 2013. – 408 p.",
    "Tanenbaum, A. Computer Networking : monogr. / A. Tanenbaum, D. Wetherall. – 6th ed. – St. Petersburg : Piter, 2021. – 912 p.",
    "Golitsyn, A. Мобильная разработка: Android, iOS, Flutter : monogr. / A. Golitsyn. – Moscow : DMK Press, 2022. – 320 p.",
    "Sommer, R. Клиент-серверные системы: проектирование и реализация : monogr. / R. Sommer. – Moscow : DiaSoft, 2018. – 384 p.",
    "Platonov, S. Психодиагностика : monogr. / S. Platonov. – St. Petersburg : Rech, 2017. – 352 p.",
    "Korolev, I. Monitoring of emotional state using mobile applications : monogr. / I. Korolev // Software Products and Systems. – 2020. – № 2. – P. 301–308.",
    "SQLAlchemy Documentation : [site]. – URL: https://docs.sqlalchemy.org/ (date of access: 05.03.2026).",
    "Pydantic Documentation : [site]. – URL: https://docs.pydantic.dev/ (date of access: 05.03.2026).",
    "Gamma, E. Design Patterns: Elements of Reusable Object-Oriented Software : monogr. / E. Gamma, R. Helm, R. Johnson, J. Vlissides. – St. Petersburg : Piter, 2020. – 368 p.",
    "Martin, R. Clean Architecture: A Craftsman's Guide to Software Structure : monogr. / R. Martin. – St. Petersburg : Piter, 2018. – 352 p.",
]

# (ключевые слова, номер источника) — устарело; см. copy_example_format.curated_refs
SOURCE_KEYWORDS: list[tuple[list[str], int]] = [
    (["Flutter"], 1),
    (["Dart"], 2),
    (["Python"], 3),
    (["FastAPI"], 4),
    (["SQLAlchemy"], 5),
    (["docs.flutter.dev", "документация Flutter"], 6),
    (["fastapi.tiangolo", "документация FastAPI"], 7),
    (["Material Design", "Material"], 8),
    (["PostgreSQL"], 9),
    (["REST API", "RESTful", "программный интерфейс"], 11),
    (["клиент-сервер", "клиент и сервер", "клиентской и серверной"], 14),
    (["мобильн"], 12),
    (["эмоциональн", "настроени", "психоэмоциональн", "самочувств"], 16),
    (["Pydantic"], 18),
    (["архитектур"], 20),
]
