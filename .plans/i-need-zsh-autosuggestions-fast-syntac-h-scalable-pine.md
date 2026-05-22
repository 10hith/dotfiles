# Plan: zsh plugins, alias upgrades, Ubuntu setup guide

## Context

The current Mac zsh setup has no plugin management, uses plain `ls`/`cat`/`grep`, and has no fzf styling or `fd` backend. The reference repo (`/Users/basavaraj/zsh`) has a clean self-managed plugin system and modern CLI tool aliases. This plan borrows those patterns, adds them to the Mac dotfiles, creates a parallel Ubuntu dotfiles tree, and updates both setup guides accordingly.

---

## Decisions (from grill session)

- Plugin manager: **self-managed** (`_zplugin_load` pattern from reference)
- Plugins: `zsh-autosuggestions`, `fast-syntax-highlighting`, `zsh-history-substring-search` — **no** `zsh-vi-mode`
- Aliases: `ls`/`ll`/`la` → `eza`, `cat` → `bat`, `grep` → `rg`; add `tree`
- fzf: `fd` as backend + UI styling (rounded borders, bat preview) — **no** `Ctrl+F` no-hidden binding
- `eza` added to Brewfile (only missing dependency)
- Ubuntu: separate `ubuntu/root/` directory mirroring `mac/root/`; `setup_ubuntu.md` in project root

---

## Files to create / modify

### Mac

| File | Action | Change |
|------|--------|--------|
| `mac/Brewfile` | Modify | Add `brew "eza"` |
| `mac/root/.zsh_plugins` | **Create** | Self-managed plugin loader (3 plugins) |
| `mac/root/.zshrc` | Modify | Source `.zsh_plugins`; replace fzf section with `fd` backend + `FZF_DEFAULT_OPTS`; remove `Alt+T` rebind |
| `mac/root/.zsh_aliases` | Modify | Replace `ls`/`ll`/`la`/`l` with `eza` variants; add `tree`; replace `cat` with `bat`; replace `grep` with `rg` |
| `mac/setup_guide.md` | Modify | Add `eza` to package list; add plugins step (auto-installs on first launch) |

### Ubuntu

| File | Action | Change |
|------|--------|--------|
| `ubuntu/root/.zshrc` | **Create** | Mac `.zshrc` minus Windsurf PATH; fzf sourced from Ubuntu path |
| `ubuntu/root/.zsh_aliases` | **Create** | Same as mac — aliases are tool-agnostic |
| `ubuntu/root/.zsh_functions` | **Create** | Identical copy of `mac/root/.zsh_functions` |
| `ubuntu/root/.zsh_plugins` | **Create** | Identical copy of `mac/root/.zsh_plugins` |
| `setup_ubuntu.md` | **Create** | Full parity guide (see structure below) |

---

## Implementation details

### `mac/root/.zsh_plugins` (new file)

```zsh
ZPLUGINDIR="$HOME/.zsh/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load zdharma-continuum fast-syntax-highlighting

# history-substring-search bindings (must come after plugin load)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
```

### fzf section in `.zshrc` (replacement)

```zsh
# ── fzf ──────────────────────────────────────────────────────────────────────
if [[ -f "$(brew --prefix fzf)/shell/key-bindings.zsh" ]]; then
  source "$(brew --prefix fzf)/shell/key-bindings.zsh"
  source "$(brew --prefix fzf)/shell/completion.zsh"
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain,numbers --line-range=:500 {}'"
```

### Alias changes in `.zsh_aliases`

Replace:
```zsh
alias ls='ls -G'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
```

With:
```zsh
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'
alias cat='bat'
alias grep='rg --color=auto'
compdef eza=ls
```

### `setup_ubuntu.md` structure

Mirrors `mac/setup_guide.md` section-by-section:
1. Prerequisites (git, curl, zsh)
2. Install packages — `apt` for base tools; `curl` installers for `zoxide`, `starship`, `eza`; Ubuntu name quirks (`batcat`→`bat`, `fdfind`→`fd` symlinks)
3. Set zsh as default shell
4. Set up fzf shell integration
5. Copy shell dotfiles — `cp ubuntu/root/...` equivalents
6. Reload & verify
7. File structure overview (shows `ubuntu/` tree)

---

## Verification

After implementation, on a Mac with the dotfiles applied:

```zsh
source ~/.zshrc          # should auto-install all 3 plugins on first run
ls                       # should show eza output with icons
cat ~/.zshrc             # should show bat syntax-highlighted output
grep foo ~/.zshrc        # should use ripgrep
Ctrl+T                   # fzf file picker with bat preview, rounded border
z <partial-dir>          # zoxide smart cd still works
zplugin-update           # should pull latest for all 3 plugins
```
