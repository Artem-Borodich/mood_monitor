# -*- coding: utf-8 -*-
"""Безопасное слияние styles.xml из примера."""
import glob
import io
import os
import re
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def merge_styles(example: str, target: str, style_ids: list[str]) -> None:
    with zipfile.ZipFile(example) as z_ex:
        styles_ex = z_ex.read("word/styles.xml").decode("utf-8")

    chunks: dict[str, str] = {}
    for sid in style_ids:
        m = re.search(
            rf'(<w:style[^>]*w:styleId="{sid}"[^>]*>.*?</w:style>)',
            styles_ex,
            re.DOTALL,
        )
        if m:
            chunks[sid] = m.group(1)

    buf = io.BytesIO()
    with zipfile.ZipFile(target, "r") as z_in:
        with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z_out:
            styles_m = z_in.read("word/styles.xml").decode("utf-8")
            for sid, chunk in chunks.items():
                if re.search(rf'w:styleId="{sid}"', styles_m):
                    styles_m = re.sub(
                        rf"<w:style[^>]*w:styleId=\"{sid}\"[^>]*>.*?</w:style>",
                        chunk,
                        styles_m,
                        count=1,
                        flags=re.DOTALL,
                    )
                else:
                    styles_m = styles_m.replace("</w:styles>", chunk + "</w:styles>")
            for item in z_in.infolist():
                data = z_in.read(item.filename)
                if item.filename == "word/styles.xml":
                    data = styles_m.encode("utf-8")
                z_out.writestr(item, data)

    with open(target, "wb") as f:
        f.write(buf.getvalue())


if __name__ == "__main__":
    from diploma_paths import diploma_path, example_docx_path

    ex = example_docx_path()
    if not ex:
        raise SystemExit("Пример .docx не найден в diploma/references/")
    mine = diploma_path()
    merge_styles(ex, mine, ["a0", "ConsPlusNonformat"])
    print("ok")
