# -*- coding: utf-8 -*-
import glob
import os
import re
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def dump_styles(path: str, label: str) -> None:
    with zipfile.ZipFile(path) as z:
        xml = z.read("word/styles.xml").decode("utf-8")
    from diploma_paths import workspace_file

    out = workspace_file("styles", f"_styles_{label}.xml.txt")
    # find all custom style names
    names = re.findall(r'w:styleId="([^"]+)"[^>]*>.*?<w:name w:val="([^"]+)"', xml, re.DOTALL)
    with open(out, "w", encoding="utf-8") as f:
        f.write(f"FILE {path}\n\n")
        for sid, name in names:
            if name in (
                "Документация",
                "ConsPlusNonformat",
                "heading 1",
                "heading 2",
                "heading 3",
                "Normal",
                "Caption",
            ) or "Heading" in name:
                m = re.search(
                    rf'<w:style w:type="paragraph" w:styleId="{re.escape(sid)}"[^>]*>(.*?)</w:style>',
                    xml,
                    re.DOTALL,
                )
                if m:
                    chunk = m.group(1)
                    f.write(f"\n--- {name} ({sid}) ---\n")
                    f.write(re.sub(r">\s*<", ">\n<", chunk[:2000]))
                    f.write("\n")
    print("wrote", out)


from diploma_paths import diploma_path

from diploma_paths import example_docx_path

mine = diploma_path()
ex = example_docx_path()
if not ex:
    raise SystemExit("Пример .docx не найден в diploma/references/")
dump_styles(ex, "example")
dump_styles(mine, "mine")
