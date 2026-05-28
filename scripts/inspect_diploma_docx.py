# -*- coding: utf-8 -*-
import glob
import os
from docx import Document

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
paths = glob.glob(os.path.join(root, "*.docx"))
if not paths:
    raise SystemExit("No docx found")
path = paths[0]
print("FILE:", path)
doc = Document(path)
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t:
        style = p.style.name if p.style else ""
        print(f"{i:4d} [{style}] {t[:100]}")
