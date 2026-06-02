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

# ── Aliases, functions & plugins ─────────────────────────────────────────────
[ -f ~/.zsh_aliases ]   && source ~/.zsh_aliases
[ -f ~/.zsh_functions ] && source ~/.zsh_functions
[ -f ~/.zsh_plugins ]   && source ~/.zsh_plugins
[ -f ~/.zsh_local ]     && source ~/.zsh_local    # machine-specific, not committed

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
