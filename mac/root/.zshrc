# ~/.zshrc — interactive shell config (macOS / zsh)

# If not running interactively, bail
[[ $- != *i* ]] && return

# ── History ──────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ── Shell options ─────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
stty -ixon                    # disable Ctrl+S / Ctrl+Q flow control

# ── Vi mode ──────────────────────────────────────────────────────────────────
bindkey -v

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ── Aliases & functions ───────────────────────────────────────────────────────
[ -f ~/.zsh_aliases ]   && source ~/.zsh_aliases
[ -f ~/.zsh_functions ] && source ~/.zsh_functions
[ -f ~/.zsh_local ]     && source ~/.zsh_local    # machine-specific, not committed

# ── fzf ──────────────────────────────────────────────────────────────────────
[ -f "$(brew --prefix fzf)/shell/key-bindings.zsh" ] && \
    source "$(brew --prefix fzf)/shell/key-bindings.zsh"
[ -f "$(brew --prefix fzf)/shell/completion.zsh" ] && \
    source "$(brew --prefix fzf)/shell/completion.zsh"

# Bind Alt-T to fzf file picker (mirrors WSL setup)
bindkey '\et' fzf-file-widget 2>/dev/null

# ── zoxide ────────────────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# Add windsurf to path
export PATH="$PATH:/Applications/Windsurf.app/Contents/Resources/app/bin"

# ── Cargo / Rust ─────────────────────────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ── uv (Python package manager) ───────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Starship prompt ───────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── Auto-start Zellij ────────────────────────────────────────────────────────
if [[ -z "$ZELLIJ" ]] && [[ -o interactive ]]; then
    zellij
fi
