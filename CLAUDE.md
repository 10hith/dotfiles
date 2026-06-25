# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal dotfiles repository for syncing configuration files across machines, primarily between Windows (via WSL) and the repository. It stores settings for various editors and tools.

## Key Commands

**Sync configuration files from system to repository:**
```bash
./sync_files.sh
```

This script reads `files_to_be_copied.md` and copies the listed configuration files into the repository. It automatically strips sensitive data (API keys, exports) from `.bashrc`.

## Repository Structure

- `Code/` - VS Code settings and keybindings
- `Windsurf/User/` - Windsurf editor settings and keybindings
- `Zed/` - Zed editor settings and keymap
- `wezterm/` - WezTerm terminal configuration (`.wezterm.lua`)
- `ghostty/` - Ghostty terminal config (`config`, symlinked to `~/.config/ghostty/config` on Mac). See `ghostty/README.md` for the cursor-trail shader setup.
- `root/` - Shell configuration (`.bashrc`, sanitized of secrets)
- `cloudflared/` - Cloudflare tunnel configuration
- `claude/` - Claude Code configuration (settings, hooks, commands, output-styles)
- `nvim/` - Neovim config (LazyVim-based). See [Neovim keymaps](#neovim-keymaps) below.
- `files_to_be_copied.md` - Manifest of files to sync (source paths, some with Windows paths via `/mnt/c/`)
- `setup_notes.txt` - Miscellaneous setup commands and notes (WSL disk reclaim, Docker cleanup, etc.)

## How sync_files.sh Works

The script parses `files_to_be_copied.md` which supports:
- Direct file paths (with `~` expansion)
- Glob patterns (`*.sh`, `**/*` for recursive)
- Inline destinations (`~/.bashrc root/.bashrc`)
- Block destinations via `Copy below to <dir>` directives

Destination inference: Files are placed based on path patterns (e.g., paths containing `/Zed/` go to `Zed/`, `/Code/User/` goes to `Code/`).

## Neovim keymaps

`nvim/lua/config/keymaps.lua` holds custom keymaps on top of LazyVim's defaults. This same config runs both in
standalone Neovim and inside VSCode via the [vscode-neovim](https://github.com/vscode-neovim/vscode-neovim) extension.

- Keymaps defined with plain `vim.keymap.set(...)` apply everywhere (standalone Neovim and VSCode).
- To add a binding that should **only** apply inside VSCode (e.g. to override a LazyVim/plugin keymap with a call to
  a VSCode command), guard it with `vim.g.vscode`, which is only truthy when running inside the vscode-neovim
  extension:

  ```lua
  if vim.g.vscode then
    vim.keymap.set("n", "9", function()
      require("vscode").action("flash-vscode.start")
    end, { desc = "Flash (VSCode)" })
  end
  ```

  Use `require("vscode").action(name)` (async) or `require("vscode").call(name)` (sync) to invoke a VSCode command
  from a keymap. Without the `vim.g.vscode` guard, the override would also apply in standalone Neovim and shadow the
  plugin's default behavior.
- flash.nvim's jump/treesitter motions are bound to `9`/`0` (see `lua/plugins/flash.lua`) rather than the more common
  `s`/`S`, specifically so they don't collide with `<leader>s...` (search/symbols) keymaps — `s`/`S` were tried first
  and `s` ended up winning races against multi-key `<leader>s...` sequences inside VSCode. `9`/`0` aren't used by any
  `<leader>` mnemonic, so there's no ambiguity. Note this shadows the default Vim motions for those keys (`9` as a
  count prefix, `0` as "start of line") — a deliberate tradeoff for collision-free Flash access.
- See the vscode-neovim README for the full API and keybinding docs: https://github.com/vscode-neovim/vscode-neovim
