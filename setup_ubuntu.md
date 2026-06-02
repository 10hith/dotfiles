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

### zellij (terminal multiplexer)

```zsh
cargo install zellij
# or download a pre-built binary:
# https://github.com/zellij-org/zellij/releases
```

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
cp ubuntu/root/.zsh_plugins ~/.zsh_plugins
cp mac/root/.justfile ~/.justfile
```

> `.justfile` is shared with the Mac setup — no Ubuntu-specific version needed.

What each file does:

| File | Purpose |
|---|---|
| `.zshrc` | Main config — history, vi mode, completions, fzf, zoxide, starship |
| `.zsh_aliases` | git, docker, AWS, navigation aliases |
| `.zsh_functions` | `envLoad`, `envAct`, `killJupyter` |
| `.zsh_plugins` | Self-managed plugin loader — auto-installs plugins on first launch |
| `.justfile` | Global just recipes |

---

## 6. Reload

```zsh
source ~/.zshrc
```

Plugins (`zsh-autosuggestions`, `zsh-history-substring-search`, `fast-syntax-highlighting`) are cloned automatically into `~/.zsh/plugins/` on first launch — no manual step required.

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
