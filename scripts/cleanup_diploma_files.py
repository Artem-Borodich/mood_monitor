# -*- coding: utf-8 -*-
"""Переименование финального диплома и удаление остальных .docx/.bak_*."""
from __future__ import annotations

import glob
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FINAL_NAME = "Дипломначалоконец.docx"
NIGHT_GLOB = "*ночн*версия*.docx"


def main() -> None:
    final_path = os.path.join(ROOT, FINAL_NAME)

    # найти «ночную версию»
    night_candidates = [
        p
        for p in glob.glob(os.path.join(ROOT, "*.docx"))
        if "ночн" in os.path.basename(p).lower() and ".bak" not in p
    ]
    if not night_candidates:
        night_candidates = [
            p
            for p in glob.glob(os.path.join(ROOT, "*.docx"))
            if "ноч" in os.path.basename(p) and ".bak" not in p
        ]

    if not os.path.isfile(final_path) and night_candidates:
        src = night_candidates[0]
        if os.path.isfile(final_path):
            os.remove(final_path)
        shutil.move(src, final_path)
        print("Переименовано:", os.path.basename(src), "->", FINAL_NAME)
    elif os.path.isfile(final_path):
        print("Уже есть:", FINAL_NAME)
    else:
        raise SystemExit("Файл «диплом ночная версия» не найден. Закройте Word.")

    removed: list[str] = []
    for pattern in (os.path.join(ROOT, "*.docx"), os.path.join(ROOT, "*.docx.bak_*")):
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
    print("Остался:", FINAL_NAME)


if __name__ == "__main__":
    main()
