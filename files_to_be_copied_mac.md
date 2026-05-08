# Mac-specific file manifest for sync_files_mac.sh
# App configs go to mac/ subdirectory to stay isolated from Windows/WSL configs.
# Shell/tool configs (root/, claude/, zellij/, cloudflared/, wezterm/) are
# shared across platforms and go to the same top-level dirs.

# --- Editor app configs (Mac-specific destinations) ---

~/Library/Application Support/Code/User/settings.json mac/Code/settings.json
~/Library/Application Support/Code/User/keybindings.json mac/Code/keybindings.json

~/Library/Application Support/Windsurf/User/settings.json mac/Windsurf/User/settings.json
~/Library/Application Support/Windsurf/User/keybindings.json mac/Windsurf/User/keybindings.json

# Zed: not yet configured on Mac — uncomment once installed
# ~/Library/Application Support/Zed/settings.json mac/Zed/settings.json
# ~/Library/Application Support/Zed/keymap.json mac/Zed/keymap.json

# WezTerm: ~/.wezterm.lua is a symlink → wezterm/.wezterm.lua (no sync needed)

# --- Shell dotfiles (shared) ---

~/.bashrc root/.bashrc
~/.bash_aliases root/.bash_aliases
~/.justfile root/.justfile
~/.bash_functions root/.bash_functions
~/.bash_local root/.bash_local
~/.inputrc root/.inputrc

# --- Mac zsh shell dotfiles ---

Copy below to mac/root
~/.zshrc
~/.zprofile
~/.zsh_aliases
~/.zsh_functions
~/.justfile
~/.inputrc

Copy below to zellij
~/.config/zellij/config.kdl

Copy below to karabiner
~/.config/karabiner/karabiner.json

Copy below to cloudflared
~/.cloudflared/setup.md
~/.cloudflared/config.yml
~/.cloudflared/*.sh

Copy below to claude
~/.claude/settings.json
~/.claude/statusline-command.sh

Copy below to claude/hooks
~/.claude/hooks/*

Copy below to claude/commands/create-hook
~/.claude/commands/create-hook/*

Copy below to claude/output-styles
~/.claude/output-styles/*.md

Copy below to claude/output-styles/.claude
~/.claude/output-styles/.claude/*
