#!/bin/bash
# mac-defaults.sh
# Apply persistent macOS defaults that may get reset after system updates.
# Managed via LaunchAgent: com.lohith.mac-defaults.plist

# Key repeat rate (lower = faster; 6 is macOS default, 2 is the macOS UI's fastest).
defaults -currentHost write NSGlobalDomain KeyRepeat -int 2

# Initial delay before repeat starts (lower = shorter delay; 68 is macOS default,
# 15 is the macOS UI's "Fast" maximum). Going below 10 risks double-typing.
defaults -currentHost write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold accent picker so keys actually repeat system-wide.
# macOS enables this by default; VS Code disables it for itself which is why
# repeat works there but nowhere else.
defaults write -g ApplePressAndHoldEnabled -bool false
