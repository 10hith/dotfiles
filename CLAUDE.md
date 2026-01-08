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
- `root/` - Shell configuration (`.bashrc`, sanitized of secrets)
- `cloudflared/` - Cloudflare tunnel configuration
- `claude/` - Claude Code configuration (settings, hooks, commands, output-styles)
- `files_to_be_copied.md` - Manifest of files to sync (source paths, some with Windows paths via `/mnt/c/`)
- `setup_notes.txt` - Miscellaneous setup commands and notes (WSL disk reclaim, Docker cleanup, etc.)

## How sync_files.sh Works

The script parses `files_to_be_copied.md` which supports:
- Direct file paths (with `~` expansion)
- Glob patterns (`*.sh`, `**/*` for recursive)
- Inline destinations (`~/.bashrc root/.bashrc`)
- Block destinations via `Copy below to <dir>` directives

Destination inference: Files are placed based on path patterns (e.g., paths containing `/Zed/` go to `Zed/`, `/Code/User/` goes to `Code/`).
