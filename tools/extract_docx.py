# -*- coding: utf-8 -*-
import sys
import zipfile
import xml.etree.ElementTree as ET

def extract(path: str) -> str:
    z = zipfile.ZipFile(path)
    xml = z.read("word/document.xml")
    root = ET.fromstring(xml)
    ns = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
    parts = []
    for t in root.iter(ns + "t"):
        if t.text:
            parts.append(t.text)
        if t.tail:
            parts.append(t.tail)
    return "".join(parts)

if __name__ == "__main__":
    p = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else None
    text = extract(p)
    if out:
        open(out, "w", encoding="utf-8").write(text)
        print("written", out)
    else:
        print(text[:15000])
