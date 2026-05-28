# -*- coding: utf-8 -*-
import glob
import re
from docx import Document

paths = [
    p
    for p in glob.glob(r"c:\mood_project\*.docx")
    if "bak" not in p and "updated" not in p and not p.split("\\")[-1].startswith("~")
]
doc = Document(paths[0])
full = "\n".join(p.text for p in doc.paragraphs if p.text.strip())
open(r"c:\mood_project\_diploma_current.txt", "w", encoding="utf-8").write(full)
# headings
for p in doc.paragraphs:
    t = p.text.strip()
    if not t:
        continue
    if p.style.name.startswith("Heading") or re.match(r"^(\d+\.?\d*)\s", t):
        print(p.style.name, t[:90])
