#!/bin/bash
# Keeps macOS awake while Citrix Viewer is running.
# Checks every 30 seconds; caffeinate runs only when Citrix is open.

CAFFEINATE_PID=""

while true; do
    if pgrep -x "Citrix Viewer" > /dev/null 2>&1; then
        if [ -z "$CAFFEINATE_PID" ] || ! kill -0 "$CAFFEINATE_PID" 2>/dev/null; then
            caffeinate -i &
            CAFFEINATE_PID=$!
            # Citrix resets keyboard settings on new sessions — reapply immediately
            defaults -currentHost write NSGlobalDomain KeyRepeat -int 5
        fi
    else
        if [ -n "$CAFFEINATE_PID" ] && kill -0 "$CAFFEINATE_PID" 2>/dev/null; then
            kill "$CAFFEINATE_PID"
            CAFFEINATE_PID=""
        fi
    fi
    sleep 30
done

# launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
# Verify: launchctl list | grep citrix-caffeinate
# 
# unload
# launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist

# reload
# launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist