# LazyVim setup (with Python / basedpyright + auto-venv)

> Purpose: a self-contained, copy-pasteable runbook for installing LazyVim on this
> Mac and configuring it for Python development with **basedpyright**, ruff, and
> **automatic `.venv` activation** (no manual `source`, no `<leader>cv`).
> Point an LLM (or yourself) at this file to execute or re-execute the setup.

---

## Context for the LLM reading this

Assumed machine state (verified 2026-06-17 on this Mac, Apple Silicon, Ghostty terminal):

- Neovim **0.12.2** (LazyVim needs ≥0.9 — fine).
- Already on PATH: `git`, `rg` (ripgrep), `fd`, `lazygit`, `cc`/`gcc`, `node`, `python3` (3.14.4), `uv`, `pip3`.
- `pipx` is **not** installed (not required — Mason handles tool installs).
- Current `~/.config/nvim` is a **minimal hand-written `init.lua`** (lazy.nvim + tokyonight +
  treesitter + telescope). It also lives in this repo at `nvim/init.lua`. LazyVim will
  **replace** it (LazyVim is a full starter config, not an add-on).
- Terminal: **Ghostty**. Needs a **Nerd Font** or LazyVim icons render as boxes.

> Reminder: LazyVim is a distribution that owns `~/.config/nvim`. Do not try to layer it
> on top of the existing `init.lua`. Back up, replace, then re-add customizations as small
> override files under `lua/config/` and `lua/plugins/`.

---

## Replicating on a new machine (fast path)

This repo already contains the full, working config under `nvim/`, including a **pinned
`lazy-lock.json`**. To reproduce this exact setup, copy it in rather than rebuilding — you
get the same plugin versions, basedpyright config, and auto-venv autocmd:

```bash
# 1. Clone this dotfiles repo (adjust path as needed)
git clone https://github.com/10hith/dotfiles.git ~/dotfiles

# 2. Back up any existing nvim config (reversible)
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true

# 3. Drop in the tracked config
mkdir -p ~/.config/nvim
cp -R ~/dotfiles/nvim/. ~/.config/nvim/

# 4. Launch — lazy.nvim installs the *pinned* versions from lazy-lock.json
nvim
```

Then inside nvim: `:Mason` to confirm `basedpyright`, `ruff`, `debugpy` (or
`:MasonInstall basedpyright ruff debugpy`), and `:LazyHealth` to verify.

Prerequisites still apply: Neovim ≥0.9, a Nerd Font in your terminal, and `git`, `rg`,
`fd`, `node`, `python3` on PATH (full list in the from-scratch steps below).

> The numbered steps below document how this config was **built from scratch** — use them
> for a fresh setup or to understand/modify the config, not for plain replication.

---

## Step 0 — Nerd Font in Ghostty (one-time)

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Then set it in the Ghostty config (`ghostty/config` in this repo / `~/.config/ghostty/config`):

```
font-family = "JetBrainsMono Nerd Font"
```

Restart Ghostty.

---

## Step 1 — Back up the current config (reversible: rename, don't delete)

```bash
mv ~/.config/nvim       ~/.config/nvim.bak
mv ~/.local/share/nvim  ~/.local/share/nvim.bak
mv ~/.local/state/nvim  ~/.local/state/nvim.bak
mv ~/.cache/nvim        ~/.cache/nvim.bak 2>/dev/null || true
```

Rollback at any time: delete the new `~/.config/nvim` and `mv` the `.bak` dirs back.

---

## Step 2 — Install the LazyVim starter

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git   # so it isn't a nested git repo inside dotfiles
```

Do **not** launch `nvim` yet — add the Python config below first so the first launch
installs everything in one pass.

---

## Step 3 — Enable Python support + basedpyright

LazyVim ships a `lang.python` extra that wires up the LSP, **ruff** (lint/format),
**debugpy** + `nvim-dap-python`, **neotest-python**, **venv-selector.nvim**, and the python
treesitter parsers. Mason auto-installs basedpyright / ruff / debugpy on first launch.

The extra defaults to **pyright**; flip it to **basedpyright** with one variable.

### 3a. Select basedpyright (must be set early)

Add to `~/.config/nvim/lua/config/options.lua` (this file loads before plugins, which is
required — the variable must be set before the extra reads it):

```lua
-- Use basedpyright instead of pyright for the lang.python extra.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff" -- default; "ruff_lsp" selects the old LSP
```

### 3b. Turn on the extra

Add the extra's import to the lazy.nvim spec in `~/.config/nvim/lua/config/lazy.lua`.
It **must** sit after `lazyvim.plugins` and before your own `{ import = "plugins" }` —
LazyVim enforces this order and warns at startup otherwise ("The order of your
`lazy.nvim` imports is incorrect"). Importing an extra from a file under `lua/plugins/`
places it *after* your own plugins and triggers that warning, so enable it here instead:

```lua
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Python language extra: basedpyright + ruff + dap + neotest + venv-selector.
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "plugins" }, -- your own plugins come last
  },
  -- ...rest of the starter's setup table unchanged...
})
```

(Alternative: `:LazyExtras` toggles extras via `lazyvim.json`, which is also trackable —
but editing `lazy.lua` keeps the whole spec explicit in one tracked file.)

---

## Step 4 — Auto-activate `.venv` on launch (the main goal)

Goal: open Neovim anywhere inside a Python project and have basedpyright, ruff, debugpy,
tests, and `:terminal` all use the project's `.venv` **with no manual step** — no shell
`source .venv/bin/activate`, no `<leader>cv`.

### Method A (recommended — covers LSP + debug + tests + terminal)

This "activates" the venv for the whole Neovim process by exporting `VIRTUAL_ENV` and
putting `.venv/bin` first on `PATH`, exactly like `source .venv/bin/activate`. Because it
runs at `VimEnter` (before any LSP attaches), basedpyright launches already pointed at the
project interpreter.

Add to `~/.config/nvim/lua/config/autocmds.lua`:

```lua
-- Auto-activate a project-local virtualenv on startup.
-- Mimics `source .venv/bin/activate` for the whole Neovim process, so basedpyright,
-- ruff, debugpy, neotest and :terminal all use the project interpreter automatically.
local function activate_local_venv()
  -- Walk upward from the current directory looking for .venv (or venv).
  local found = vim.fs.find({ ".venv", "venv" }, {
    upward = true,
    type = "directory",
    path = vim.fn.getcwd(),
  })[1]
  if not found then
    return
  end

  local python = found .. "/bin/python"
  if vim.fn.executable(python) == 0 then
    return
  end

  vim.env.VIRTUAL_ENV = found
  vim.env.PATH = found .. "/bin:" .. vim.env.PATH
end

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Auto-activate project .venv",
  once = true,
  callback = activate_local_venv,
})
```

**Limitation:** this runs once at startup, matching the "launch nvim inside a project" use
case. If you `:cd` to a *different* project in the same session, it won't re-activate — open
a fresh nvim, or also use Method B (which is per-project automatically).

### Method B (optional — pins basedpyright per project root)

LSP-only, but project-aware: basedpyright starts once per project root, and this picks the
`.venv` relative to that root each time. Safe to use alongside Method A. The extra's import
already lives in `lazy.lua` (Step 3b); this is a plain plugin override, so create
`~/.config/nvim/lua/plugins/python.lua` with **only** the lspconfig override below — do
**not** add the extras import here, or you'll re-trigger the import-order warning:

```lua
return {
  -- Point basedpyright at the project's .venv automatically (per project root).
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          before_init = function(_, config)
            local venv = vim.fs.find({ ".venv", "venv" }, {
              upward = true,
              type = "directory",
              path = config.root_dir or vim.fn.getcwd(),
            })[1]
            if venv then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = venv .. "/bin/python"
            end
          end,
        },
      },
    },
  },
}
```

> Recommendation: start with **Method A** alone. Add Method B only if you frequently switch
> projects within one nvim session and want the LSP to follow without a restart.

---

## Step 5 — First launch & verify

```bash
nvim
```

On first launch LazyVim bootstraps lazy.nvim and installs plugins. Then, inside nvim:

- `:Lazy sync` — finish/refresh plugin install.
- `:Mason` — watch `basedpyright`, `ruff`, `debugpy` install (or `:MasonInstall basedpyright ruff debugpy`).
- `:LazyHealth` — should be all green.
- Open a `.py` file in a project that has a `.venv`, then `:LspInfo` — confirm
  **basedpyright** is attached and using `.venv/bin/python`.
- `:lua print(vim.env.VIRTUAL_ENV)` — should print the project's `.venv` path (Method A working).

---

## Per-project workflow (with `uv`)

```bash
cd my-project
uv venv               # creates ./.venv
uv pip install -e .   # or: uv sync
nvim .                # .venv auto-activates; basedpyright resolves imports
```

Without a `.venv` present, basedpyright falls back to the system `python3` and will flag
third-party imports as unresolved — that's expected; create the venv.

---

## Using flash.nvim (fast on-screen jumps)

**flash.nvim** ships with LazyVim — nothing to install. It lets you jump anywhere on
screen by typing a few characters and then a one-key label. The override file
`~/.config/nvim/lua/plugins/flash.lua` is currently a **no-op** (every line commented out),
so flash runs with LazyVim's defaults below.

### Default keymaps (LazyVim)

| Key | Modes | Action |
|-----|-------|--------|
| `s` | normal, visual, operator | **Flash jump** — type 2 chars, then press the label to teleport there |
| `S` | normal, visual, operator | **Flash Treesitter** — label + select syntax nodes (functions, blocks, args) |
| `r` | operator-pending | **Remote Flash** — run an operator at a remote spot (e.g. `yr` to yank elsewhere, cursor returns) |
| `R` | operator, visual | **Treesitter Search** — search + treesitter selection combined |
| `<c-s>` | command-line / search | **Toggle Flash** while typing a `/` or `?` search |
| `<c-space>` | normal, visual, operator | Treesitter incremental selection (`<c-space>` grow, `<bs>` shrink) |

### Everyday use

- **Jump:** press `s`, type the 2 chars before where you want to land, then the highlighted
  label. With one match it jumps immediately.
- **Operators:** flash works after operators — `ds<char><label>` deletes to a far spot,
  `ys` / `cs` / `=s` likewise. `r` lets the operator act remotely without moving the cursor.
- **f / F / t / T are enhanced** by flash's `char` mode (on by default): after `f`, labels
  appear so you can reach *any* matching char on the line, and `;` / `,` repeat as usual.
- **Search:** start a normal search with `/`, and flash labels the matches — press a label to
  jump straight to one. Use `<c-s>` mid-search to toggle flash on/off.

### Customizing (uncomment the override)

To make flash labels **persist on every `/` search** (instead of toggling with `<c-s>`),
uncomment the block in `lua/plugins/flash.lua` — that sets `modes.search.enabled = true`.
Uncommenting the `keys` table lets you remap any of the above; uncommenting
`char.jump_labels = true` adds labels to `f`/`t` immediately. Restart nvim (or `:Lazy reload
flash.nvim`) after editing.

---

## Dotfiles tracking

The config is now a **directory** (`~/.config/nvim/`), not a single `init.lua`. Update the
sync so the whole dir is tracked:

- Track at least: `lua/config/options.lua`, `lua/config/autocmds.lua`, `lua/config/keymaps.lua`,
  `lua/plugins/*.lua`, `init.lua`, `lazyvim.json` (if used), and `lazy-lock.json`
  (keep it — pins plugin versions for reproducible installs).
- `files_to_be_copied.md` has per-subdir blocks (`nvim`, `nvim/lua/config`, `nvim/lua/plugins`)
  for this — needed because the sync script flattens each block with `basename`.
- **Note:** `sync_files.sh` is `set -e` and dies on the first missing source. On macOS the
  manifest's `/mnt/c/...` (Windows/WSL) paths don't exist, so the script can't run here — it's
  effectively WSL-only. Capture nvim changes on the Mac with a manual copy instead:
  ```bash
  cp -p ~/.config/nvim/{init.lua,lazy-lock.json,stylua.toml} ~/dotfiles/nvim/
  cp -p ~/.config/nvim/lua/config/*.lua  ~/dotfiles/nvim/lua/config/
  cp -p ~/.config/nvim/lua/plugins/*.lua ~/dotfiles/nvim/lua/plugins/
  ```

---

## Troubleshooting

- **Icons are boxes / question marks** → Nerd Font not set in Ghostty (Step 0).
- **basedpyright not attaching** → `:Mason` and confirm it installed; `:LazyHealth`;
  check `vim.g.lazyvim_python_lsp` is set in `options.lua` (loads before plugins).
- **Imports unresolved despite a venv** → confirm `.venv/bin/python` exists; `:LspInfo` to
  see which interpreter basedpyright uses; `:lua print(vim.env.VIRTUAL_ENV)`. If empty, the
  Method A autocmd didn't find the venv (was nvim launched outside the project tree?).
- **debugpy / neotest fail to install (Python 3.14 is bleeding-edge)** → some packages lack
  3.14 wheels. Install an older interpreter (`brew install python@3.12`) and create project
  venvs with `uv venv --python 3.12`. basedpyright and ruff are standalone binaries and are
  unaffected.
- **Want pyright instead** → set `vim.g.lazyvim_python_lsp = "pyright"`.

---

## Rollback (undo everything)

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
mv ~/.config/nvim.bak      ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim
mv ~/.local/state/nvim.bak ~/.local/state/nvim
mv ~/.cache/nvim.bak       ~/.cache/nvim 2>/dev/null || true
```
