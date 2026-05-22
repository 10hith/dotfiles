# Mac Setup Guide

Follow this top to bottom on a fresh Mac. Everything in the repo is referenced here — nothing left to memory.

---

## 1. Clone the repo

```zsh
git clone https://github.com/10hith/dotfiles ~/dotfiles
cd ~/dotfiles
```

---

## 2. Homebrew

If not already installed:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add Homebrew to the current session (one-time — `.zprofile` handles this on subsequent logins):

```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## 3. Install packages

```zsh
brew bundle --file=mac/Brewfile
```

Installs: `starship`, `zoxide`, `fzf`, `eza`, `zellij`, `just`, `lazygit`, `git`, `gh`, `ripgrep`, `fd`, `bat`, `jq`, `wget`

---

## 4. Nerd Font

Required for `eza --icons` and Starship glyphs to render correctly.

```zsh
brew install --cask font-jetbrains-mono-nerd-font
```

Then set `JetBrainsMono Nerd Font` (or `JetBrainsMono NF`) as the font in your terminal (WezTerm, iTerm2, etc.).

---

## 5. Set up fzf shell integration (one-time)

```zsh
$(brew --prefix fzf)/install --key-bindings --completion --no-update-rc
```

---

## 6. Copy shell dotfiles

```zsh
cp mac/root/.zprofile ~/.zprofile
cp mac/root/.zshrc ~/.zshrc
cp mac/root/.zsh_aliases ~/.zsh_aliases
cp mac/root/.zsh_functions ~/.zsh_functions
cp mac/root/.zsh_plugins ~/.zsh_plugins
cp mac/root/.justfile ~/.justfile
cp mac/root/.inputrc ~/.inputrc
```

| File | Purpose |
|---|---|
| `.zprofile` | Login shell — Homebrew env, cargo PATH |
| `.zshrc` | Main config — history, vi mode, completions, fzf, zoxide, starship |
| `.zsh_aliases` | git, docker, AWS, navigation, and app aliases |
| `.zsh_functions` | `envLoad`, `envAct`, `killJupyter` |
| `.zsh_plugins` | Self-managed plugin loader — auto-installs plugins on first launch |
| `.justfile` | Global just recipes |
| `.inputrc` | Vi-mode readline with `[N]`/`[I]` mode indicators |

---

## 7. WezTerm

Config lives at `~/.wezterm.lua`. Create a symlink so edits in the repo take effect immediately without resyncing:

```zsh
ln -sf ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
```

---

## 8. Zellij

```zsh
mkdir -p ~/.config/zellij
cp zellij/config.kdl ~/.config/zellij/config.kdl
```

---

## 9. Windsurf

```zsh
cp mac/Windsurf/User/settings.json \
  ~/Library/Application\ Support/Windsurf/User/settings.json

cp mac/Windsurf/User/keybindings.json \
  ~/Library/Application\ Support/Windsurf/User/keybindings.json
```

---

## 10. VS Code

```zsh
cp mac/Code/settings.json \
  ~/Library/Application\ Support/Code/User/settings.json

cp mac/Code/keybindings.json \
  ~/Library/Application\ Support/Code/User/keybindings.json
```

---

## 11. Karabiner-Elements

Install Karabiner-Elements from https://karabiner-elements.pqrs.org, then copy the config:

```zsh
mkdir -p ~/.config/karabiner
cp karabiner/karabiner.json ~/.config/karabiner/karabiner.json
```

Karabiner reads the config automatically — no restart needed.

---

## 12. Kanata (optional — home row mods)

Kanata provides tap-hold home row mods with release-order logic (more accurate than Karabiner for fast typing). See comments in `kanata/kanata.kbd` for details.

Install:

```zsh
brew install kanata
```

Deploy config:

```zsh
mkdir -p ~/.config/kanata
cp kanata/kanata.kbd ~/.config/kanata/kanata.kbd
```

Run:

```zsh
sudo kanata --cfg ~/.config/kanata/kanata.kbd
```

> Kanata requires root to access the keyboard device. You can set up a LaunchDaemon to run it at boot — see the kanata docs for the plist template.

---

## 13. LaunchAgents

LaunchAgents run at login. Two are tracked in this repo.

### com.lohith.mac-defaults (keyboard tuning — recommended)

Applies fast key-repeat and disables the press-and-hold accent picker at every login (macOS resets these after updates).

> **Before installing:** the plist hardcodes the path to `mac/scripts/mac-defaults.sh` using the username `basavaraj`. If your username differs, edit `mac/com.lohith.mac-defaults.plist` and replace the path before copying.

```zsh
cp mac/com.lohith.mac-defaults.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.mac-defaults.plist
```

Verify it loaded:

```zsh
launchctl list | grep mac-defaults
```

### com.lohith.citrix-caffeinate (optional — Citrix users only)

Prevents macOS sleep while Citrix Viewer is running and re-applies key-repeat when a Citrix session starts (Citrix resets it).

```zsh
cp mac/automation/com.lohith.citrix-caffeinate.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lohith.citrix-caffeinate.plist
```

See `mac/automation/README.md` for reload/disable instructions and the related `keep_active.py` anti-idle script.

---

## 14. Conda (optional)

Install Miniconda from the official installer (not Homebrew):

```zsh
# Download and run installer, then:
conda init zsh
```

`conda init zsh` appends its block directly to `~/.zshrc`.

---

## 15. Reload

```zsh
source ~/.zshrc
```

Plugins (`zsh-autosuggestions`, `zsh-history-substring-search`, `fast-syntax-highlighting`) clone themselves into `~/.zsh/plugins/` automatically on first launch.

---

## Verify everything works

```zsh
starship --version        # prompt
z --version               # zoxide
fzf --version             # fuzzy finder — Ctrl+R and Ctrl+T should work
ls                        # eza with icons (needs Nerd Font in terminal)
cat ~/.zshrc              # bat — syntax highlighted
grep foo ~/.zshrc         # ripgrep
jj                        # global just recipes
lg                        # lazygit TUI
zellij                    # terminal multiplexer
zplugin-update            # pull latest for all zsh plugins
```

---

## Syncing changes back to the repo

Run after editing any of the tracked files live in `~`:

```zsh
./sync_files_mac.sh
```

Editor settings (Windsurf, VS Code) and Karabiner are also listed in `files_to_be_copied_mac.md` and are pulled in automatically by the sync script.

---

## What lives where

```
dotfiles/
├── mac/
│   ├── Brewfile                        ← package manifest
│   ├── setup_guide.md                  ← this file
│   ├── com.lohith.mac-defaults.plist   ← LaunchAgent: keyboard defaults at login
│   ├── KEYBOARD.md                     ← key repeat / press-and-hold reference
│   ├── root/                           ← zsh dotfiles → ~/ (synced via sync_files_mac.sh)
│   │   ├── .zprofile
│   │   ├── .zshrc
│   │   ├── .zsh_aliases
│   │   ├── .zsh_functions
│   │   ├── .zsh_plugins
│   │   ├── .justfile
│   │   └── .inputrc
│   ├── Code/                           ← VS Code settings → ~/Library/Application Support/Code/User/
│   ├── Windsurf/                       ← Windsurf settings → ~/Library/Application Support/Windsurf/User/
│   ├── scripts/
│   │   ├── mac-defaults.sh             ← keyboard tuning (run by LaunchAgent)
│   │   └── citrix-caffeinate.sh        ← Citrix sleep-prevention (run by LaunchAgent)
│   └── automation/
│       ├── com.lohith.citrix-caffeinate.plist
│       ├── keep_active.py              ← anti-idle for Citrix session (run on demand)
│       └── README.md
├── karabiner/
│   └── karabiner.json                  ← → ~/.config/karabiner/karabiner.json
├── kanata/
│   └── kanata.kbd                      ← → ~/.config/kanata/kanata.kbd
├── zellij/
│   └── config.kdl                      ← → ~/.config/zellij/config.kdl
├── wezterm/
│   └── .wezterm.lua                    ← symlinked from ~/.wezterm.lua
├── tips.md                             ← feature cheat sheet
└── setup_ubuntu.md                     ← Ubuntu equivalent of this file
```

`.zsh_local` is intentionally not committed — put machine-specific overrides there (API tokens, custom PATH entries).
