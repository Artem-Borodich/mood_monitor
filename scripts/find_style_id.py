# -*- coding: utf-8 -*-
import glob
import os
import re
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ex = [
    p
    for p in glob.glob(os.path.join(ROOT, "*.docx"))
    if "Диплома" not in os.path.basename(p) and ".bak" not in p
][0]
with zipfile.ZipFile(ex) as z:
    xml = z.read("word/styles.xml").decode("utf-8")
for m in re.finditer(
    r'<w:style[^>]*w:styleId="([^"]+)"[^>]*>.*?<w:name w:val="([^"]+)"',
    xml,
    re.DOTALL,
):
    if "окумент" in m.group(2) or m.group(2) in ("Normal", "ConsPlusNonformat"):
        sid, name = m.group(1), m.group(2)
        chunk = re.search(
            rf'<w:style[^>]*w:styleId="{sid}"[^>]*>(.*?)</w:style>',
            xml,
            re.DOTALL,
        )
        text = chunk.group(1) if chunk else ""
        sz = re.search(r'w:sz w:val="(\d+)"', text)
        ind = re.search(r'w:firstLine="(\d+)"', text)
        line = re.search(r'w:line="(\d+)"', text)
        jc = re.search(r'w:jc w:val="(\w+)"', text)
        print(name, sid, "sz", sz, "ind", ind, "line", line, "jc", jc)
