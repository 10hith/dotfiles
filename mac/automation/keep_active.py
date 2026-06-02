# /// script
# dependencies = [
#   "pyautogui",
# ]
# ///
# run with caffeinate d python keep_active.py
import subprocess

import pyautogui
import time

CITRIX_BUNDLE_ID = "com.citrix.receiver.icaviewer.mac"

while True:
    # Use AppleScript activate — more reliable than `open -b` for already-running apps
    subprocess.run(
        ["osascript", "-e", f'tell application id "{CITRIX_BUNDLE_ID}" to activate'],
        check=False,
    )
    time.sleep(1)  # let app come to focus

    pyautogui.keyDown("cmd")
    pyautogui.press("3")
    pyautogui.keyUp("cmd")
    time.sleep(1)

    # Scroll down (negative = down, positive = up)
    pyautogui.scroll(-100)   # scroll down
    time.sleep(1)
    pyautogui.scroll(100)    # scroll back up

    # time.sleep(5)  # 3 minutes
    time.sleep(55)  # 2 minutes for testing