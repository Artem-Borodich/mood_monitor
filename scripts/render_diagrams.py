# -*- coding: utf-8 -*-
"""Render PlantUML diagrams to PNG for the diploma."""
from __future__ import annotations

import os
import subprocess
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIAGRAMS = os.path.join(ROOT, "docs", "diagrams")
TOOLS = os.path.join(ROOT, "tools")
JAR = os.path.join(TOOLS, "plantuml.jar")
PLANTUML_URL = (
    "https://github.com/plantuml/plantuml/releases/download/v1.2024.7/"
    "plantuml-1.2024.7.jar"
)


def ensure_jar() -> str:
    os.makedirs(TOOLS, exist_ok=True)
    if not os.path.isfile(JAR):
        print("Downloading PlantUML jar...")
        urllib.request.urlretrieve(PLANTUML_URL, JAR)
    return JAR


def render_with_java() -> bool:
    jar = ensure_jar()
    puml_files = [
        f
        for f in os.listdir(DIAGRAMS)
        if f.endswith(".puml") and not f.startswith("_")
    ]
    if not puml_files:
        return False
    cmd = ["java", "-jar", jar, "-tpng", "-o", DIAGRAMS]
    cmd.extend(os.path.join(DIAGRAMS, f) for f in puml_files)
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print("Java PlantUML failed:", e)
        return False


def render_with_online() -> bool:
    try:
        import zlib

        import httpx  # noqa: F401
    except ImportError:
        pass

    try:
        from plantuml import PlantUML  # type: ignore
    except ImportError:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "plantuml", "-q"],
            check=True,
        )
        from plantuml import PlantUML  # type: ignore

    server = PlantUML(url="http://www.plantuml.com/plantuml/png/")
    ok = True
    for name in os.listdir(DIAGRAMS):
        if not name.endswith(".puml"):
            continue
        src = os.path.join(DIAGRAMS, name)
        out = os.path.join(DIAGRAMS, name.replace(".puml", ".png"))
        try:
            server.processes_file(src, outfile=out)
            print("Rendered (online):", out)
        except Exception as e:
            print("Online render failed for", name, e)
            ok = False
    return ok


def main() -> None:
    if render_with_java():
        print("Rendered with local PlantUML jar.")
        return
    print("Falling back to online PlantUML...")
    if not render_with_online():
        raise SystemExit("Could not render diagrams.")


if __name__ == "__main__":
    main()
