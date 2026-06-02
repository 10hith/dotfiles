# Shell Tips — Getting the Most Out of This Setup

A practical reference for every feature in this zsh config. Organized by workflow so you reach for the right tool at the right moment.

---

## Navigating Directories

### zoxide — smart `cd` that learns

```zsh
z proj          # jumps to the most-visited directory matching "proj"
z dot conf      # multi-word: matches a path containing both "dot" and "conf"
zi              # interactive picker — fzf over your frecency list
cd -            # jump back to the previous directory (like browser back)
```

> After a few days of use, `z` replaces `cd` entirely. You rarely type full paths again.

### autocd — skip typing `cd`

```zsh
~/dotfiles      # just type the path — no cd needed
..              # go up one level
../..           # go up two levels
```

---

## Finding Files — fzf

### Ctrl+T — fuzzy file picker (includes hidden files)

Press `Ctrl+T` at any point in a command to insert a file path:

```zsh
cat <Ctrl+T>            # pick a file to cat
code <Ctrl+T>           # pick a file to open in VS Code
git add <Ctrl+T>        # stage a specific file interactively
```

The right panel shows a `bat` preview of the file as you browse.

### Ctrl+R — fuzzy history search

Press `Ctrl+R` to search everything you've ever typed:

```zsh
<Ctrl+R> docker run     # find that long docker run command you used last week
<Ctrl+R> aws s3         # find any aws s3 command
```

Type any fragment — it doesn't have to be the start of the command.

---

## History — Smarter Arrow Keys

With `zsh-history-substring-search`, up/down arrows filter by what you've already typed:

```zsh
git <Up>        # cycles only through commands that start with "git"
docker <Up>     # cycles only through docker commands
z <Up>          # cycles only through zoxide jumps
```

This replaces blindly hammering `↑` until you find what you want.

---

## Autosuggestions — Accept Without Retyping

`zsh-autosuggestions` shows a greyed-out completion based on history as you type:

| Key | Action |
|-----|--------|
| `→` or `End` | Accept the full suggestion |
| `Ctrl+→` | Accept one word of the suggestion |
| Keep typing | Ignore it and continue |

```zsh
# You type: git push
# Shell suggests: git push origin main   (greyed out)
# Press → to accept the whole thing
```

---

## Listing Files — eza

```zsh
ls              # icons, colour-coded by type
ll              # detailed: permissions, size, date, git status per file
la              # same as ll but includes hidden files (dotfiles)
tree            # tree view of the current directory
tree src/       # tree view of a specific directory
```

The `--git` flag in `ll` / `la` shows whether each file is modified, staged, or untracked — useful when you can't remember what you changed.

---

## Reading Files — bat

`cat` is aliased to `bat`. It adds:
- Syntax highlighting
- Line numbers
- Git diff markers (shows changed lines vs HEAD)

```zsh
cat ~/.zshrc            # highlighted zsh config
cat main.py             # highlighted Python
cat README.md           # highlighted Markdown
bat --plain file.txt    # plain output, no line numbers (for piping)
```

---

## Searching — ripgrep

`grep` is aliased to `rg`. It's faster, respects `.gitignore`, and has better defaults:

```zsh
grep "TODO" .                   # search current directory recursively
grep "def main" src/            # search in a specific directory
grep -l "import pandas" .       # list files that match, not lines
grep "error" logs/ -A 3         # show 3 lines of context after each match
grep "useState" . --type ts     # search only TypeScript files
```

> Unlike plain `grep`, `rg` skips `node_modules`, `.git`, and anything in `.gitignore` automatically.

---

## Git Aliases

| Alias | Command | When to use |
|-------|---------|-------------|
| `gs` | `git status` | Always — before anything else |
| `gl` | `git log --oneline` | Quick commit history |
| `lg` | `lazygit` | Full TUI: stage hunks, rebase, resolve conflicts |
| `ga` | `git add` | Stage specific files |
| `gaa` | `git add --all` | Stage everything |
| `gcm "msg"` | `git commit -m` | Quick commit |
| `gca` | `git commit --amend` | Fix the last commit message or add a file |
| `gco branch` | `git checkout` | Switch branches |
| `gcb branch` | `git checkout -b` | New branch |
| `gP` | `git push` | Push |
| `gPf` | `git push --force-with-lease` | Force push safely (won't overwrite others' work) |
| `gp` | `git pull` | Pull |

### lazygit (`lg`) key moments

Open `lg` when you want to:
- Stage individual hunks (not whole files) — press `h` on a file
- Interactive rebase — press `e` on a branch
- Resolve merge conflicts visually
- Cherry-pick commits between branches

---

## Python Workflow

```zsh
j py            # activate venv (checks venv/ then .venv/) + set PYTHONPATH + load .env
envAct          # activate venv only
envLoad         # export all vars from .env into the shell
setPyPath       # export PYTHONPATH=$(pwd)
```

---

## Zellij — Terminal Multiplexer

S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 automatically when you open a terminal. Key bindings:

| Key | Action |
|-----|--------|
| `Ctrl+p` then `n` | New pane |
| `Ctrl+p` then `d` | Split pane down |
| `Ctrl+p` then `r` | Split pane right |
| `Ctrl+p` then `x` | Close pane |
| `Ctrl+t` then `n` | New tab |
| `Ctrl+t` then `r` | Rename tab |
| `Alt+←/→` | Move between panes |
| `Ctrl+o` then `d` | Detach session (keeps it running) |

```zsh
zellij attach   # re-attach to a detached session
zellij ls       # list sessions
```

---

## Yazi — File Manager

A terminal file manager with rich previews (images, PDFs, videos, syntax-highlighted text), git status per file, and vim-style navigation.

```zsh
yy              # open yazi; terminal cd's to wherever you quit — primary entry point
y               # open yazi without cd-on-quit (browse only)
```

### Navigation

| Key | Action |
|-----|--------|
| `h` / `l` | Go up / into directory |
| `j` / `k` | Move down / up in file list |
| `Enter` | Open file with default opener |
| `o` | Open file with a picker |
| `f` | Jump to file by first char (type a letter) |

### File operations

| Key | Action |
|-----|--------|
| `y` | Yank (copy) selected file |
| `x` | Cut selected file |
| `p` | Paste |
| `d` | Move to trash |
| `r` | Rename |
| `Space` | Toggle selection |

### Preview pane

| Key | Action |
|-----|--------|
| `Tab` | Maximize / restore preview pane |
| `` ` `` | Hide / show preview pane |

Previews: syntax-highlighted code (bat), images, PDFs, video thumbnails. Files show git status indicators (M, A, ?) the same way `ll` does with `eza --git`.

---

## Plugin Management

```zsh
zplugin-update  # pull latest for all 3 plugins
```

Plugins are cloned into `~/.zsh/plugins/` on first shell launch. You never need to install them manually.

---

## Misc

```zsh
reload          # source ~/.zshrc — picks up alias/config changes without restarting
aliases         # print all your aliases to the terminal
jj              # list global just recipes (zwork, zattach, zdump)
```
