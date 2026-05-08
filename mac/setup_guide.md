# Mac Setup Guide

Reproduced from the dotfiles repo. This mirrors the WSL2/Ubuntu bash setup but uses zsh (macOS default since Catalina).

---

## 1. Homebrew

If not already installed:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then add Homebrew to your shell (one-time, for the current session):

```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## 2. Install packages

```zsh
brew bundle --file=mac/Brewfile
```

Installs: `starship`, `zoxide`, `fzf`, `zellij`, `just`, `lazygit`, `git`, `gh`, `ripgrep`, `fd`, `bat`, `jq`, `wget`

---

## 3. Set up fzf shell integration (one-time)

```zsh
$(brew --prefix fzf)/install --key-bindings --completion --no-update-rc
```

---

## 4. Copy shell dotfiles

```zsh
cp mac/root/.zprofile ~/.zprofile
cp mac/root/.zshrc ~/.zshrc
cp mac/root/.zsh_aliases ~/.zsh_aliases
cp mac/root/.zsh_functions ~/.zsh_functions
cp mac/root/.justfile ~/.justfile
cp mac/root/.inputrc ~/.inputrc
```

What each file does:

| File | Purpose |
|---|---|
| `.zprofile` | Login shell — Homebrew env, cargo PATH |
| `.zshrc` | Main config — history, vi mode, completions, fzf, zoxide, starship, conda |
| `.zsh_aliases` | git, docker, AWS, navigation, and app aliases |
| `.zsh_functions` | `envLoad`, `envAct`, `killJupyter` |
| `.justfile` | Global just recipes: `zwork`, `zattach`, `zdump` |
| `.inputrc` | Vi-mode readline with `[N]`/`[I]` mode indicators |

---

## 5. Conda (optional)

Install Miniconda from the official installer (not Homebrew) to match the WSL setup:

```zsh
# Download and run installer, then:
conda init zsh
```

`conda init zsh` will write the init block directly into `~/.zshrc` with the correct local path.

---

## 6. Reload

```zsh
source ~/.zshrc
```

---

## Verify everything works

```zsh
starship --version        # prompt theme
z --version               # zoxide smart cd
fzf --version             # fuzzy finder (Ctrl+R should work)
jj                        # lists global just recipes
lg                        # opens lazygit TUI
zellij                    # opens terminal multiplexer
gs                        # git status alias
```

---

## Syncing changes back to the repo

`files_to_be_copied_mac.md` has a `Copy below to mac/root` block. Run the sync script to pull live `~` files back into the repo:

```zsh
./sync_files_mac.sh
```

---

## What lives where

```
mac/
├── Brewfile               ← package manifest
├── setup_guide.md         ← this file
├── root/                  ← zsh dotfiles (committed, synced via sync_files_mac.sh)
│   ├── .zprofile
│   ├── .zshrc
│   ├── .zsh_aliases
│   ├── .zsh_functions
│   ├── .justfile
│   └── .inputrc
├── Code/                  ← VS Code settings (Mac-specific)
└── Windsurf/              ← Windsurf settings (Mac-specific)
```

`.zsh_local` is intentionally not committed — put machine-specific overrides there (e.g. work API tokens, custom PATH entries).
