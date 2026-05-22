# mac/automation

Two Citrix-related automations live here. They solve different problems and can be used independently or together.

| Automation | Solves | Runs as |
|---|---|---|
| `com.lohith.citrix-caffeinate.plist` | macOS going to sleep while Citrix Viewer is running | LaunchAgent (always-on, polls in background) |
| `keep_active.py` | Citrix *session* going idle and disconnecting on the server side | Foreground Python script, run on demand |

The first keeps your **Mac** awake. The second keeps your **Citrix session** awake. If you're getting kicked out of Citrix even though your Mac is on, you need the second. If your screen sleeps and Citrix loses its connection, you need the first. They stack fine.

---

## com.lohith.citrix-caffeinate (LaunchAgent)

**Purpose:** While `Citrix Viewer` is running, prevent display and idle sleep. Also re-applies the fast `KeyRepeat` setting each time a Citrix session starts, since Citrix resets it.

**Files:**
- Plist: `mac/automation/com.lohith.citrix-caffeinate.plist`
- Script: `mac/scripts/citrix-caffeinate.sh` (polls every 30s for the `Citrix Viewer` process; runs `caffeinate -di` only while it's open)
- Logs: `~/Library/Logs/citrix-caffeinate.log`

**Install / run at login:**

```bash
cp ~/dotfiles/mac/automation/com.lohith.citrix-caffeinate.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
launchctl list | grep citrix-caffeinate
```

A line like `-  0  com.lohith.citrix-caffeinate` confirms it's loaded. The `-` PID is normal — the parent script is sleeping between polls.

**Reload after editing the script or plist:**

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
cp ~/dotfiles/mac/automation/com.lohith.citrix-caffeinate.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
```

**Disable / uninstall:**

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
rm ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
```

**Debug:** `tail -f ~/Library/Logs/citrix-caffeinate.log`

---

## keep_active.py (foreground anti-idle)

**Purpose:** Stops the Citrix session itself from idling out by activating Citrix Viewer, sending `Cmd+3`, and scrolling — on a loop. Use this when the server-side session timeout is the problem (e.g. you're stepping away but want the session to stay logged in).

**Files:**
- Script: `mac/automation/keep_active.py`

**Run on demand:**

```bash
caffeinate -d uv run ~/dotfiles/mac/automation/keep_active.py
```

The script uses an inline `# /// script` block declaring `pyautogui` as its only dependency, so `uv run` will handle the environment. Wrapping with `caffeinate -d` is belt-and-suspenders if `citrix-caffeinate` isn't enabled.

**Stop:** `Ctrl+C` in the terminal where it's running.

**Notes:**
- The script bypasses Karabiner's hyper-key remapping by activating Citrix Viewer via its bundle ID (`com.citrix.receiver.icaviewer.mac`).
- Default loop interval is 55s (tuned during testing). Adjust the trailing `time.sleep(...)` if your session times out faster or slower.
- macOS will prompt for Accessibility permission the first time `pyautogui` tries to send input. Grant it to your terminal app in System Settings → Privacy & Security → Accessibility.
- Not run as a LaunchAgent on purpose — you generally only want this active during specific stretches (e.g. a long-running job on the virtual desktop), not all the time.
