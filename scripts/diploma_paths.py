# -*- coding: utf-8 -*-
"""Пути к диплому и рабочим файлам проекта."""
from __future__ import annotations

import glob
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Основной текст диплома (единственный .docx в корне diploma/)
DIPLOMA_DIR = os.path.join(ROOT, "diploma")
DIPLOMA_FILENAME = "Дипломначалоконец.docx"

# Справочные PDF и примеры оформления
REFERENCES_DIR = os.path.join(DIPLOMA_DIR, "references")
BACKUPS_DIR = os.path.join(DIPLOMA_DIR, "backups")

# Временные экспорты, отчёты скриптов, логи (не основной текст)
WORKSPACE_DIR = os.path.join(ROOT, "workspace", "diploma")
WORKSPACE_EXPORTS = os.path.join(WORKSPACE_DIR, "exports")
WORKSPACE_REPORTS = os.path.join(WORKSPACE_DIR, "reports")
WORKSPACE_STYLES = os.path.join(WORKSPACE_DIR, "styles")
WORKSPACE_LOGS = os.path.join(WORKSPACE_DIR, "logs")
WORKSPACE_IMPORTS = os.path.join(WORKSPACE_DIR, "imports")


def _ensure_dirs() -> None:
    for d in (
        DIPLOMA_DIR,
        REFERENCES_DIR,
        BACKUPS_DIR,
        WORKSPACE_EXPORTS,
        WORKSPACE_REPORTS,
        WORKSPACE_STYLES,
        WORKSPACE_LOGS,
        WORKSPACE_IMPORTS,
    ):
        os.makedirs(d, exist_ok=True)


def diploma_path() -> str:
    _ensure_dirs()
    path = os.path.join(DIPLOMA_DIR, DIPLOMA_FILENAME)
    if os.path.isfile(path):
        return path
    raise FileNotFoundError(
        f"{DIPLOMA_FILENAME} не найден в {DIPLOMA_DIR}. Закройте Word."
    )


def docx_paths() -> list[str]:
    """Список docx для скриптов (только основной диплом)."""
    return [diploma_path()]


def docx_search_globs() -> list[str]:
    """Каталоги для поиска docx (основной + справочные примеры)."""
    return [
        os.path.join(DIPLOMA_DIR, "*.docx"),
        os.path.join(REFERENCES_DIR, "*.docx"),
    ]


def iter_docx_candidates(*, include_backups: bool = False) -> list[str]:
    """Все docx в diploma/ и references/ (без основного при фильтре)."""
    paths: list[str] = []
    patterns = list(docx_search_globs())
    if include_backups:
        patterns.append(os.path.join(BACKUPS_DIR, "*.docx"))
    for pattern in patterns:
        paths.extend(glob.glob(pattern))
    return sorted(set(paths))


def example_docx_path() -> str | None:
    """Пример оформления (не основной диплом), если есть в references/."""
    main = DIPLOMA_FILENAME
    for p in iter_docx_candidates():
        bn = os.path.basename(p)
        if bn == main or ".bak" in bn or bn.startswith("~$"):
            continue
        return p
    return None


def workspace_file(subdir: str, name: str) -> str:
    _ensure_dirs()
    base = {
        "exports": WORKSPACE_EXPORTS,
        "reports": WORKSPACE_REPORTS,
        "styles": WORKSPACE_STYLES,
        "logs": WORKSPACE_LOGS,
        "imports": WORKSPACE_IMPORTS,
    }.get(subdir, WORKSPACE_DIR)
    return os.path.join(base, name)
