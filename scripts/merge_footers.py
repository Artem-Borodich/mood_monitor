# -*- coding: utf-8 -*-
"""Копирование колонтитулов из примера (без дублирования путей в zip)."""
from __future__ import annotations

import glob
import io
import os
import re
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def merge_footers(example: str, target: str) -> None:
    with zipfile.ZipFile(example) as z_ex:
        footers = {n: z_ex.read(n) for n in z_ex.namelist() if re.match(r"word/footer\d+\.xml$", n)}
        rels_ex = z_ex.read("word/_rels/document.xml.rels").decode("utf-8")
        doc_ex = z_ex.read("word/document.xml").decode("utf-8")

    if not footers:
        return

    sects = re.findall(r"<w:sectPr[\s\S]*?</w:sectPr>", doc_ex)
    title_sect = sects[0] if len(sects) > 1 else ""
    main_sect = sects[-1] if sects else ""

    buf = io.BytesIO()
    with zipfile.ZipFile(target, "r") as z_in:
        names_in = set(z_in.namelist())
        with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z_out:
            rels_t = z_in.read("word/_rels/document.xml.rels").decode("utf-8")
            doc_t = z_in.read("word/document.xml").decode("utf-8")

            max_id = max((int(m.group(1)) for m in re.finditer(r'Id="rId(\d+)"', rels_t)), default=0)
            for fn, data in footers.items():
                if fn in names_in:
                    continue
                base = os.path.basename(fn)
                max_id += 1
                rels_t = rels_t.replace(
                    "</Relationships>",
                    f'<Relationship Id="rId{max_id}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="{base}"/>'
                    + "\n</Relationships>",
                )

            if title_sect and "Введение" in doc_t:
                intro_m = re.search(
                    r"<w:p[\s\S]*?<w:t[^>]*>Введение</w:t>[\s\S]*?</w:p>",
                    doc_t,
                )
                if intro_m:
                    pos = intro_m.start()
                    prev_end = doc_t.rfind("</w:p>", 0, pos)
                    if prev_end > 0:
                        sect_p = f"<w:p><w:pPr>{title_sect}</w:pPr></w:p>"
                        doc_t = doc_t[: prev_end + 6] + sect_p + doc_t[prev_end + 6 :]

            if main_sect:
                doc_t = re.sub(
                    r"<w:sectPr[\s\S]*?</w:sectPr>\s*</w:body>",
                    main_sect + "</w:body>",
                    doc_t,
                    count=1,
                )

            for item in z_in.infolist():
                data = z_in.read(item.filename)
                if item.filename == "word/_rels/document.xml.rels":
                    data = rels_t.encode("utf-8")
                elif item.filename == "word/document.xml":
                    data = doc_t.encode("utf-8")
                z_out.writestr(item, data)
            for fn, data in footers.items():
                if fn not in names_in:
                    z_out.writestr(fn, data)

    with open(target, "wb") as f:
        f.write(buf.getvalue())


if __name__ == "__main__":
    from diploma_paths import diploma_path, example_docx_path

    ex = example_docx_path()
    if not ex:
        raise SystemExit("Пример .docx не найден в diploma/references/")
    mine = diploma_path()
    merge_footers(ex, mine)
    print("OK:", mine)
