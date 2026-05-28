import glob
import os
import re
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ex = [p for p in glob.glob(os.path.join(ROOT, "*.docx")) if "Диплома" not in os.path.basename(p)][0]
with zipfile.ZipFile(ex) as z:
    xml = z.read("word/styles.xml").decode("utf-8")
print("a0 present", 'w:styleId="a0"' in xml)
m = re.search(
    r"(<w:style w:type=\"paragraph\" w:styleId=\"a0\"[^>]*>.*?</w:style>)",
    xml,
    re.DOTALL,
)
print("match1", bool(m))
m2 = re.search(r'(<w:style[^>]*w:styleId="a0"[^>]*>.*?</w:style>)', xml, re.DOTALL)
print("match2", bool(m2), len(m2.group(1)) if m2 else 0)
