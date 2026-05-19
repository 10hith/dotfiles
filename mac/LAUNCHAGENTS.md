# LaunchAgents

## Active

| Agent | Plist | Purpose |
|---|---|---|
| com.lohith.mac-defaults | mac/com.lohith.mac-defaults.plist | Re-applies KeyRepeat and other defaults at login |

## Disabled

### com.lohith.citrix-caffeinate

Keeps macOS awake while Citrix Viewer is running, and re-applies keyboard settings when a new Citrix session starts.

**Script:** `mac/scripts/citrix-caffeinate.sh`
**Plist:** `mac/com.lohith.citrix-caffeinate.plist`

Disabled because it was causing issues at launch. Re-enable when needed:

```bash
# 1. Install the plist
cp ~/dotfiles/mac/com.lohith.citrix-caffeinate.plist ~/Library/LaunchAgents/

# 2. Load it (no reboot needed)
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist

# 3. Verify it's running
launchctl list | grep citrix-caffeinate

# To disable again:
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
rm ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
```
