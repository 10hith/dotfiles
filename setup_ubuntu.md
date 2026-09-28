# Ubuntu Setup Guide

Self-contained setup guide for a fresh Ubuntu machine. Mirrors the Mac setup but uses `apt` and manual installers where Homebrew equivalents don't exist.

---

## 1. Prerequisites

```zsh
sudo apt update && sudo apt install -y \
  zsh git curl wget jq \
  fzf ripgrep fd-find bat
```

Ubuntu installs `bat` as `batcat` and `fd` as `fdfind` — symlink them so aliases work:

```zsh
mkdir -p ~/.local/bin
ln -sf $(which batcat) ~/.local/bin/bat
ln -sf $(which fdfind) ~/.local/bin/fd
```

---

## 2. Install tools not in apt

### zoxide (smart cd)

```zsh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### starship (prompt)

```zsh
curl -sS https://starship.rs/install.sh | sh
```

### eza (modern ls)

```zsh
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza
```

### deja (autosuggestions)

[deja](https://github.com/Giammarco-Ferranti/deja) provides the ghost-text autosuggestions (fuzzy, directory-aware, next-command prediction). The installer downloads the release binary to `~/.local/bin/deja` and verifies its checksum:

```zsh
# SHELL=/bin/sh stops the installer appending its own init lines to ~/.zshrc —
# .zsh_plugins loads deja itself, and loading it twice double-sources the integration.
curl -fsSL https://raw.githubusercontent.com/Giammarco-Ferranti/deja/main/install.sh | SHELL=/bin/sh sh
~/.local/bin/deja import    # one-time: seed deja from ~/.zsh_history
```

Optional — if you skip this, `.zsh_plugins` falls back to `zsh-autosuggestions` automatically (unlike the Mac, there's no Homebrew so it won't auto-install deja).

To update later: rerun the installer, then `deja daemon --restart`.

### zellij (terminal multiplexer)

```zsh
cargo install zellij
# or download a pre-built binary:
# https://github.com/zellij-org/zellij/releases
```

### neovim (editor)

```zsh
# The apt version is often outdated; install the latest AppImage instead:
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -C ~/.local -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
# Add to PATH (already included if ~/.local/bin is in PATH via .bashrc)
export PATH="$HOME/.local/nvim-linux-x86_64/bin:$PATH"
```

Deploy config (from repo root):

```zsh
mkdir -p ~/.config/nvim
cp nvim/init.lua ~/.config/nvim/init.lua
```

On first launch, lazy.nvim and plugins (tokyonight, treesitter) install automatically.

### lazygit (git TUI)

```zsh
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
  | grep tag_name | cut -d'"' -f4 | sed 's/v//')
curl -Lo lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit lazygit.tar.gz
```

### yazi (file manager)

```zsh
# Install yazi + ya CLI via cargo (cargo is available via .cargo/env in .zshrc)
cargo install --locked yazi-fm yazi-cli

# Preview dependencies
sudo apt install -y ffmpegthumbnailer poppler-utils imagemagick p7zip-full
```

Deploy config (from repo root):

```zsh
mkdir -p ~/.config/yazi
cp yazi/yazi.toml    ~/.config/yazi/yazi.toml
cp yazi/keymap.toml  ~/.config/yazi/keymap.toml
cp yazi/init.lua     ~/.config/yazi/init.lua
```

Install plugins and flavor (one-time, after yazi is installed):

```zsh
ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:max-preview
ya pkg add yazi-rs/plugins:hide-preview
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:jump-to-char
ya pkg add "yazi-rs/flavors:catppuccin-mocha"
```

---

### just (task runner)

```zsh
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
```

### gh (GitHub CLI)

```zsh
sudo apt install -y gh
# or: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

---

## 3. Set zsh as your default shell

```zsh
chsh -s $(which zsh)
```

Log out and back in for the change to take effect.

---

## 4. Set up fzf shell integration (one-time)

```zsh
$(dpkg -L fzf | grep key-bindings.zsh | head -1 | xargs dirname)/../../../bin/fzf --version \
  && /usr/share/doc/fzf/examples/key-bindings.zsh  # already sourced via .zshrc if file exists
```

fzf integration is sourced automatically in `.zshrc` from `/usr/share/doc/fzf/examples/`. No manual step needed if installed via `apt`.

---

## 5. Copy shell dotfiles

```zsh
cp ubuntu/root/.zshrc ~/.zshrc
cp ubuntu/root/.zsh_aliases ~/.zsh_aliases
cp ubuntu/root/.zsh_functions ~/.zsh_functions
cp mac/root/.zsh_plugins ~/.zsh_plugins
cp mac/root/.justfile ~/.justfile
```

> `.zsh_plugins` and `.justfile` are shared with the Mac setup — no Ubuntu-specific versions needed. `.zsh_plugins`' Homebrew auto-install is skipped when `brew` isn't present.

What each file does:

| File | Purpose |
|---|---|
| `.zshrc` | Main config — history, vi mode, completions, fzf, zoxide, starship |
| `.zsh_aliases` | git, docker, AWS, navigation aliases |
| `.zsh_functions` | `envLoad`, `envAct`, `killJupyter` |
| `.zsh_plugins` | Self-managed plugin loader — auto-installs plugins on first launch; deja autosuggestions (falls back to zsh-autosuggestions) |
| `.justfile` | Global just recipes |

---

## 6. Reload

```zsh
source ~/.zshrc
```

Plugins (`deja`, `zsh-history-substring-search`, `fast-syntax-highlighting`) are cloned automatically into `~/.zsh/plugins/` on first launch — no manual step required.

Autosuggestions use deja when its binary is installed (see [deja](#deja-autosuggestions) above), otherwise `zsh-autosuggestions` is cloned and loaded instead — never both. Keys: `→` or `Ctrl+L` accepts, `Ctrl+N` cycles alternatives, Tab stays normal completion. See `tips.md` for the full list.

---

## Verify everything works

```zsh
starship --version        # prompt theme
z --version               # zoxide smart cd
fzf --version             # fuzzy finder (Ctrl+R / Ctrl+T should work)
lg                        # opens lazygit TUI
zellij                    # opens terminal multiplexer
gs                        # git status alias
ls                        # should show eza output with icons
cat ~/.zshrc              # should show bat syntax-highlighted output
zplugin-update            # updates all zsh plugins
deja ping                 # autosuggestion daemon → pong (skip if using the zsh-autosuggestions fallback)
yazi --version            # file manager
yy                        # open yazi with cd-on-quit (navigate somewhere, quit, shell follows)
```

---

## Syncing changes back to the repo

Edit `files_to_be_copied.md` (or create a `files_to_be_copied_ubuntu.sh`) to pull live `~` files back into `ubuntu/root/`.

---

## What lives where

```
ubuntu/
└── root/                  ← zsh dotfiles (committed)
    ├── .zshrc
    ├── .zsh_aliases
    ├── .zsh_functions
    └── .zsh_plugins       ← plugin loader (plugins cloned to ~/.zsh/plugins/ at runtime)

setup_ubuntu.md            ← this file (project root)
```

`.zsh_local` is intentionally not committed — put machine-specific overrides there (e.g. work API tokens, custom PATH entries).
