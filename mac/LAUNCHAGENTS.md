# LaunchAgents

## Active

| Agent | Plist | Purpose |
|---|---|---|
| com.lohith.mac-defaults | mac/com.lohith.mac-defaults.plist | Re-applies KeyRepeat and other defaults at login |
| com.lohith.citrix-caffeinate | mac/automation/com.lohith.citrix-caffeinate.plist | Keeps macOS awake while Citrix Viewer is running; re-applies KeyRepeat on new Citrix sessions |

## Notes

### com.lohith.citrix-caffeinate

**Script:** `mac/scripts/citrix-caffeinate.sh` (polls every 30s)
**Plist:** `mac/automation/com.lohith.citrix-caffeinate.plist`
**Logs:** `~/Library/Logs/citrix-caffeinate.log`

Was previously disabled due to unspecified "issues at launch" — re-enabled 2026-05-20 with logging on so any recurrence is debuggable.

See `mac/automation/README.md` for install/disable steps and the related `keep_active.py` automation.
