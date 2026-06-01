# -*- coding: utf-8 -*-
"""Переименование финального диплома и удаление лишних .docx в diploma/."""
from __future__ import annotations

import glob
import os
import shutil

from diploma_paths import (
    BACKUPS_DIR,
    DIPLOMA_DIR,
    DIPLOMA_FILENAME,
    docx_search_globs,
)

FINAL_NAME = DIPLOMA_FILENAME


def main() -> None:
    final_path = os.path.join(DIPLOMA_DIR, FINAL_NAME)

    night_candidates: list[str] = []
    for pattern in docx_search_globs():
        for p in glob.glob(pattern):
            bn = os.path.basename(p)
            if "ночн" in bn.lower() and ".bak" not in bn and bn != FINAL_NAME:
                night_candidates.append(p)

    if not os.path.isfile(final_path) and night_candidates:
        src = night_candidates[0]
        shutil.move(src, final_path)
        print("Переименовано:", os.path.basename(src), "->", FINAL_NAME)
    elif os.path.isfile(final_path):
        print("Уже есть:", FINAL_NAME)
    else:
        raise SystemExit("Файл диплома не найден. Закройте Word.")

    removed: list[str] = []
    patterns = list(docx_search_globs()) + [
        os.path.join(BACKUPS_DIR, "*.docx"),
        os.path.join(DIPLOMA_DIR, "*.docx.bak_*"),
    ]
    for pattern in patterns:
        for path in glob.glob(pattern):
            bn = os.path.basename(path)
            if bn == FINAL_NAME:
                continue
            if bn.startswith("~$"):
                continue
            try:
                os.remove(path)
                removed.append(bn)
            except PermissionError:
                print("Занят, пропуск:", bn)

    print(f"Удалено файлов: {len(removed)}")
    print("Остался:", os.path.join("diploma", FINAL_NAME))


if __name__ == "__main__":
    main()
