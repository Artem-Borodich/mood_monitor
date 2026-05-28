# -*- coding: utf-8 -*-
"""Путь к основному файлу диплома в корне проекта."""
from __future__ import annotations

import glob
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIPLOMA_FILENAME = "Дипломначалоконец.docx"


def diploma_path() -> str:
    path = os.path.join(ROOT, DIPLOMA_FILENAME)
    if os.path.isfile(path):
        return path
    raise FileNotFoundError(
        f"{DIPLOMA_FILENAME} не найден в {ROOT}. Закройте Word."
    )


def docx_paths() -> list[str]:
    """Список docx для скриптов (только основной диплом)."""
    path = diploma_path()
    return [path]
