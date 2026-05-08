---
name: mac-app-launcher
description: >
  Use this skill whenever the user wants to create a macOS app or hotkey that silently focuses,
  activates, or brings to front another application — especially for use with Raycast, Alfred,
  Spotlight, or any launcher that assigns keyboard shortcuts to apps. Common triggers include:
  "create a hotkey to focus [app]", "make a shortcut to switch to Citrix/VDI/virtual desktop",
  "build a macOS app that activates [app]", "Raycast keeps showing a startup dialog", "the app
  shows 'Press Run to run this script'", or any request to create a silent launcher/switcher.
  Also trigger if the user has a Script Editor .app that shows a startup dialog on every hotkey
  press — this skill explains the correct fix. ALWAYS use this skill for any macOS app-focus
  or silent-launcher workflow.
---

# mac-app-launcher

Create a **silent macOS shell bundle app** that activates any target application — no startup
dialog, no Dock icon, works perfectly as a Raycast/Alfred hotkey.

## Why not Script Editor / osacompile?

`osacompile` creates an AppleScript applet (basically a Script Editor document packaged as an
app). Every time macOS launches it, Script Editor's runtime shows a "Press Run to run this
script" dialog — and no plist tweak reliably suppresses it. Avoid this path entirely.

The correct approach: build a real `.app` bundle where the executable is a plain **bash script**
that calls `osascript` inline. No Script Editor runtime, no dialog, zero startup overhead.

## Workflow

### Step 1 — Find the target app's bundle ID

```bash
mdls -name kMDItemCFBundleIdentifier /Applications/AppName.app
```

For example:
- Citrix Viewer: `com.citrix.receiver.icaviewer.mac`
- Safari: `com.apple.Safari`

If the app isn't in `/Applications`, try `~/Applications/` or use Spotlight to find it.

### Step 2 — Create the builder Python script

Write a Python script to the user's outputs/workspace folder. It builds the full `.app` bundle
programmatically so no Xcode or developer tools are needed.

Key parameters to fill in:
- `APP_NAME` — the short name (e.g. `vcse`, `citrix-focus`)
- `BUNDLE_ID` — the target app's bundle identifier found in Step 1
- `INSTALL_PATH` — use `/Applications/` so Raycast/Alfred can index it

```python
import os, stat, subprocess

APP_NAME = "my-launcher"              # ← change this
TARGET_BUNDLE_ID = "com.example.app"  # ← change this
app = f"/Applications/{APP_NAME}.app"

# Remove old version if it exists
subprocess.run(["rm", "-rf", app])

# Bundle structure
os.makedirs(app + "/Contents/MacOS", exist_ok=True)
os.makedirs(app + "/Contents/Resources", exist_ok=True)

# The executable: a bash script that uses osascript inline (no applet runtime)
script_path = app + f"/Contents/MacOS/{APP_NAME}"
with open(script_path, "w") as f:
    f.write("#!/bin/bash\n")
    f.write(f'osascript -e \'tell application id "{TARGET_BUNDLE_ID}" to activate\'\n')
os.chmod(script_path, stat.S_IRWXU | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)

# Info.plist — LSUIElement=true hides it from the Dock
with open(app + "/Contents/Info.plist", "w") as f:
    f.write(f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>{APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.{APP_NAME}</string>
    <key>CFBundleName</key>
    <string>{APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
''')

# PkgInfo — required for macOS to recognise this as a proper APPL bundle
with open(app + "/Contents/PkgInfo", "w") as f:
    f.write("APPL????")

# Strip quarantine so macOS doesn't block the first launch
subprocess.run(["xattr", "-cr", app])

print(f"✅ {APP_NAME}.app created at {app}")
```

### Step 3 — Create the AppleScript runner

Write a tiny AppleScript that executes the Python builder via `do shell script`. The user will
open this in Script Editor and click ▶ Run.

```applescript
do shell script "python3 '/path/to/your/builder_script.py'"
display dialog "✅ App created! Assign your hotkey in Raycast." buttons {"OK"} default button "OK"
```

Save both files to a location the user can reach via Finder (e.g., the Claude outputs folder).

### Step 4 — Run via Script Editor

Because Cowork's Terminal access is restricted to "click" tier (no typing), deliver via Script Editor:

1. Open **Finder** → **Go → Go to Folder** (⌘⇧G) → navigate to where the `.applescript` file
   was saved
2. Double-click the `.applescript` — it opens in Script Editor
3. Click ▶ **Run**
4. The success dialog confirms the app was created

### Step 5 — Assign the hotkey in Raycast (or Alfred)

- Open **Raycast** → search for the new app by name
- Click the `⌘` icon next to it → assign the desired hotkey
- Test it — the target app should come to front silently, no dialog

## Important tips

**Avoid Raycast caching issues**: If you're rebuilding an app that Raycast already has cached
(e.g., replacing an old `vcse.app`), use a fresh versioned name on the first build
(e.g., `vcse_v1.app`), confirm it works, then rename and reassign the hotkey. This bypasses
stale caches that would otherwise keep launching the old version.

**App in the right place**: Raycast indexes `/Applications/` by default. `~/Applications/` may
work but `/Applications/` is safer and more reliable.

**Citrix Viewer focus stealing**: If Citrix Viewer is open on an external display, it sometimes
steals keyboard focus while the user is typing in other apps. This is a Citrix behaviour, not a
bug in the launcher.

**Finding bundle IDs for apps not in /Applications**:
```bash
find /Applications ~/Applications -name "*.app" -maxdepth 2 | while read a; do
  id=$(mdls -name kMDItemCFBundleIdentifier "$a" 2>/dev/null | awk '{print $3}' | tr -d '"')
  echo "$id  $a"
done | grep -i <keyword>
```

## What NOT to do

- **Don't use `osacompile`** — it always produces the "Press Run" startup dialog
- **Don't use `defaults write ... OSAAppletShowStartupScreen -bool NO`** — doesn't work reliably
- **Don't install to `~/Desktop` or `~/Downloads`** — Raycast won't index it as a launchable app
- **Don't skip `PkgInfo`** — without it, macOS may not recognise the bundle as an APPL
- **Don't forget `xattr -cr`** — without stripping quarantine, macOS Gatekeeper may block launch
