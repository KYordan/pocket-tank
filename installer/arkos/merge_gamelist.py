#!/usr/bin/env python3
"""Add/update Pocket Tank while keeping every other Ports entry intact."""
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

current, addition, output = map(Path, sys.argv[1:4])
if current.exists():
    tree = ET.parse(current)
    root = tree.getroot()
    if root.tag != "gameList":
        raise SystemExit(f"Unexpected gamelist root: {root.tag}")
else:
    root = ET.Element("gameList")
    tree = ET.ElementTree(root)

incoming = ET.parse(addition).getroot()
for new_game in incoming.findall("game"):
    new_path = new_game.findtext("path")
    for old_game in list(root.findall("game")):
        if old_game.findtext("path") == new_path:
            root.remove(old_game)
    root.append(new_game)

ET.indent(tree, space="  ")
tree.write(output, encoding="UTF-8", xml_declaration=True)
