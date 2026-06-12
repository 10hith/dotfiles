#!/usr/bin/env python3
"""Add Hyper+Y -> run "Dictate to Cursor" Shortcuts rule to live Karabiner config.

Karabiner intercepts the key at HID level, so this works even in WezTerm
(where the Shortcuts app's own global hotkey doesn't fire).
Run once:  python3 ~/dotfiles/scripts/add_dictate_hotkey.py
Karabiner auto-reloads the config; no restart needed.
"""
import json
import shutil
from pathlib import Path

SHORTCUT_NAME = "Dictate to Cursor"  # must match the name in the Shortcuts app
DESC = "Hyper+Y: run Dictate to Cursor shortcut"

cfg_path = Path.home() / ".config/karabiner/karabiner.json"
cfg = json.loads(cfg_path.read_text())

rule = {
    "description": DESC,
    "manipulators": [
        {
            "type": "basic",
            "from": {
                "key_code": "y",
                "modifiers": {"mandatory": ["command", "control", "option", "shift"]},
            },
            "to": [{"shell_command": f"shortcuts run \"{SHORTCUT_NAME}\" &"}],
        }
    ],
}

profile = next(p for p in cfg["profiles"] if p.get("selected"))
rules = profile.setdefault("complex_modifications", {}).setdefault("rules", [])

if any(r.get("description") == DESC for r in rules):
    print("Rule already present; nothing to do.")
else:
    shutil.copy2(cfg_path, cfg_path.with_suffix(".json.bak"))
    rules.insert(0, rule)
    cfg_path.write_text(json.dumps(cfg, indent=4) + "\n")
    print(f"Added rule to {cfg_path} (backup: karabiner.json.bak)")
