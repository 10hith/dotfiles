-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ── Action group (<leader>a) ────────────────────────────────────────────────
-- Operate on the visual selection (or current line in normal mode), prefixing a
-- `# file:line` comment header:
--   <leader>ay  copy it to the system clipboard
--   <leader>as  send it into an agent window (bracketed paste, no submit), then focus that agent
--   <leader>aS  same but submit (Enter) and stay in nvim
local function ref(l1, l2)
  local file = vim.fn.expand("%:.") -- path relative to cwd
  if l1 == l2 then
    return string.format("# %s:%d", file, l1)
  end
  return string.format("# %s:%d-%d", file, l1, l2)
end

local function payload(l1, l2)
  if l1 > l2 then
    l1, l2 = l2, l1
  end
  return ref(l1, l2) .. "\n" .. table.concat(vim.fn.getline(l1, l2), "\n")
end

local function copy(l1, l2)
  vim.fn.setreg("+", payload(l1, l2))
  vim.notify("Copied " .. ref(l1, l2) .. " to clipboard", vim.log.levels.INFO)
end

local function send_to_pane(l1, l2, submit)
  require("config.rex-selection").send(payload(l1, l2), submit)
end

local function vrange()
  return vim.fn.getpos("v")[2], vim.fn.getpos(".")[2]
end

vim.keymap.set("x", "<leader>ay", function()
  copy(vrange())
end, { desc = "Copy selection + file:line ref" })
vim.keymap.set("n", "<leader>ay", function()
  local l = vim.fn.line(".")
  copy(l, l)
end, { desc = "Copy line + file:line ref" })

vim.keymap.set("x", "<leader>as", function()
  local a, b = vrange()
  send_to_pane(a, b)
end, { desc = "Send selection to pane" })
vim.keymap.set("n", "<leader>as", function()
  local l = vim.fn.line(".")
  send_to_pane(l, l)
end, { desc = "Send line to pane" })

vim.keymap.set("x", "<leader>aS", function()
  local a, b = vrange()
  send_to_pane(a, b, true)
end, { desc = "Send selection to pane + submit" })
vim.keymap.set("n", "<leader>aS", function()
  local l = vim.fn.line(".")
  send_to_pane(l, l, true)
end, { desc = "Send line to pane + submit" })

-- Jump to nearest `# %%` cell marker below and center it (mirrors old VSCode-vim "4" mapping)
vim.keymap.set("n", "4", function()
  vim.fn.search("# %%")
  vim.cmd("normal! zz")
end, { desc = "Next # %% cell, centered", silent = true })

-- Jump to nearest `# %%` cell marker above and center it (mirrors old VSCode-vim "6" mapping)
vim.keymap.set("n", "6", function()
  vim.fn.search("# %%", "b")
  vim.cmd("normal! zz")
end, { desc = "Previous # %% cell, centered", silent = true })

-- VSCode-neovim only keymaps live in their own module (require is a no-op in
-- standalone nvim, where the module returns early on the vim.g.vscode guard).
require("config.vscode")

-- LSP document symbols: keep LazyVim's default <leader>ss (works everywhere)
-- and additionally bind Cmd+Shift+O to the same picker. The Cmd chord relies
-- on the terminal forwarding the kitty keyboard protocol through herdr, which
-- isn't guaranteed, so <leader>ss stays as the reliable fallback rather than
-- being deleted.
if not vim.g.vscode then
  vim.keymap.set("n", "<leader>ss", function()
    Snacks.picker.lsp_symbols()
  end, { desc = "Goto Symbol" })
  vim.keymap.set("n", "<D-S-o>", function()
    Snacks.picker.lsp_symbols()
  end, { desc = "Goto Symbol" })

  -- Same idea for the file picker: Cmd+P mirrors LazyVim's <leader><space>
  -- ("Find Files (Root Dir)"), which stays bound as the fallback. Confirmed
  -- working: Ghostty claims super+shift+p (command palette) but leaves super+p
  -- free, and herdr only claims cmd+1..9, so the chord reaches nvim intact.
  vim.keymap.set("n", "<D-p>", function()
    LazyVim.pick("files")()
  end, { desc = "Find Files (Root Dir)" })

  -- And for lazygit: Cmd+Shift+G mirrors LazyVim's <leader>gg ("Lazygit (Root
  -- Dir)"), which stays bound as the fallback. Unlike Cmd+P, this chord needs
  -- help from the terminal — Ghostty binds super+shift+g to
  -- navigate_search:previous by default, so ghostty/config unbinds it to let
  -- the key through. Root dir (not cwd) to match <leader>gg; <leader>gG is the
  -- cwd variant.
  vim.keymap.set("n", "<D-S-g>", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Lazygit (Root Dir)" })

  -- And Ctrl+Tab for the buffer picker, mirroring LazyVim's <leader>bj (which
  -- stays bound). Not a Cmd chord, but it needs the same kitty keyboard
  -- protocol support: in legacy terminal encoding Ctrl+Tab is byte-identical
  -- to Tab, so nvim can only tell them apart when the terminal sends the
  -- disambiguating escape. Ghostty binds ctrl+tab to next_tab by default, so
  -- ghostty/config unbinds it to let the key through.
  vim.keymap.set("n", "<C-Tab>", "<cmd>BufferLinePick<cr>", { desc = "Pick Buffer" })

  -- And Cmd+Shift+E for the file explorer, mirroring LazyVim's <leader>e
  -- ("Explorer Snacks (root dir)"), which stays bound as the fallback. Ghostty
  -- doesn't claim super+shift+e, so unlike Cmd+Shift+G this needs no unbind.
  vim.keymap.set("n", "<D-S-e>", function()
    Snacks.explorer({ cwd = LazyVim.root() })
  end, { desc = "Explorer Snacks (root dir)" })
end

local ok, wk = pcall(require, "which-key")
if ok then
  wk.add({ { "<leader>a", group = "action", mode = { "n", "x" } } })
end
