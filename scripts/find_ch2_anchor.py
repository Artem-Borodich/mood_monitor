# -*- coding: utf-8 -*-
import glob
import os
from docx import Document

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
paths = [
    p
    for p in glob.glob(os.path.join(root, "*.docx"))
    if ".bak_" not in p
    and not os.path.basename(p).startswith("~$")
]
paths.sort(key=lambda p: ("_updated" not in p, p))
doc = Document(paths[-1] if paths else paths[0])
print("Using:", paths[-1] if paths else "none")
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if not t:
        continue
    if "2 " in t[:5] or t.startswith("2.") or "Программная реализация" in t or "2.1" in t[:4]:
        print(i, repr(p.style.name), t[:90])
