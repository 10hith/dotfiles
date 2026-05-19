# Mac Keyboard Settings

These are applied automatically at login via `mac/scripts/mac-defaults.sh` (LaunchAgent: `com.lohith.mac-defaults`).
Run any command manually to apply immediately without a reboot.

## Key Repeat Rate

```bash
# Check current value
defaults read -g KeyRepeat

# Set repeat speed (lower = faster; 6 is macOS default, 2 is macOS UI max, 1 is fastest)
defaults -currentHost write NSGlobalDomain KeyRepeat -int 2
```

## Initial Repeat Delay

How long you must hold a key before it starts repeating.
Too low = double-typing on single keypresses.

```bash
# Check current value
defaults read -g InitialKeyRepeat

# Set delay (lower = shorter; 68 is macOS default, 15 is the macOS UI's fastest)
defaults -currentHost write NSGlobalDomain InitialKeyRepeat -int 15
```

## Press-and-Hold (Accent Picker)

macOS shows an accent picker when you hold a key, which disables repeat entirely.
VS Code disables this for itself — which is why repeat works in VS Code but nowhere else by default.

```bash
# Disable accent picker system-wide (restores key repeat everywhere)
defaults write -g ApplePressAndHoldEnabled -bool false

# Re-enable if needed (restores macOS default behaviour)
defaults write -g ApplePressAndHoldEnabled -bool true
```

> Requires logout/login to take full effect after first applying.

## Apply All at Once

```bash
defaults -currentHost write NSGlobalDomain KeyRepeat -int 2
defaults -currentHost write NSGlobalDomain InitialKeyRepeat -int 15
defaults write -g ApplePressAndHoldEnabled -bool false
```
