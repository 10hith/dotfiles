-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ── Action group (<leader>a) ────────────────────────────────────────────────
-- Operate on the visual selection (or current line in normal mode), prefixing a
-- `# file:line` comment header:
--   <leader>ay  copy it to the system clipboard
--   <leader>as  send it into another zellij pane (bracketed paste, no submit), then focus that pane
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

-- JSON nulls decode to vim.NIL (which is truthy); normalize to a display string.
local function str(v)
  if v == nil or v == vim.NIL then
    return "?"
  end
  return tostring(v)
end

-- Other terminal panes in nvim's *current tab* (excludes plugins, floating,
-- suppressed and exited panes, plus nvim's own pane). Scoping to the current tab
-- keeps the picker short even with many tabs/panes open. The --json output also
-- carries `pane_command` directly, so no second `list-panes` call is needed.
local function candidate_panes()
  local out = vim.system({ "zellij", "action", "list-panes", "--json" }):wait()
  if out.code ~= 0 then
    return {}
  end
  local ok, panes = pcall(vim.json.decode, out.stdout)
  if not ok then
    return {}
  end
  local self_id = tonumber(vim.env.ZELLIJ_PANE_ID) -- reliably set inside zellij
  -- nvim's tab = the tab containing nvim's own pane. (list-panes spans all tabs;
  -- there's no per-tab query flag, so we filter on tab_id ourselves.)
  local my_tab
  for _, p in ipairs(panes or {}) do
    if self_id and p.id == self_id then
      my_tab = p.tab_id
      break
    end
  end
  local res = {}
  for _, p in ipairs(panes or {}) do
    if
      not p.is_plugin
      and not p.is_floating
      and not p.is_suppressed
      and not p.exited
      and not (self_id and p.id == self_id)
      and (my_tab == nil or p.tab_id == my_tab) -- same tab (fallback: all, if self not found)
    then
      -- pane_command is only sometimes present in the JSON; fall back to the title.
      local cmd = p.pane_command
      if cmd == nil or cmd == vim.NIL then
        cmd = nil
      end
      res[#res + 1] = {
        id = "terminal_" .. p.id,
        label = cmd and string.format("%s — %s", cmd, str(p.title)) or str(p.title),
      }
    end
  end
  return res
end

-- Bracketed-paste `text` into pane_id. submit => send Enter and stay in nvim;
-- otherwise move focus to the target so you can finish the message there.
local function deliver(pane_id, text, submit)
  vim.system({ "zellij", "action", "write-chars", "--pane-id", pane_id, "\27[200~" .. text .. "\27[201~" }):wait()
  if submit then
    vim.system({ "zellij", "action", "write-chars", "--pane-id", pane_id, "\r" }):wait()
  else
    vim.system({ "zellij", "action", "focus-pane-id", pane_id }):wait()
  end
end

local function send_to_pane(l1, l2, submit)
  local text = payload(l1, l2)
  if not vim.env.ZELLIJ then -- graceful fallback outside zellij
    vim.fn.setreg("+", text)
    vim.notify("Not in zellij — copied to clipboard instead", vim.log.levels.WARN)
    return
  end
  local panes = candidate_panes()
  if #panes == 0 then
    vim.notify("No target pane found", vim.log.levels.WARN)
    return
  end
  if #panes == 1 then
    deliver(panes[1].id, text, submit)
    return
  end
  vim.ui.select(panes, {
    prompt = "Send snippet to pane:",
    format_item = function(p)
      return p.label
    end,
  }, function(choice)
    if choice then
      deliver(choice.id, text, submit)
    end
  end)
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

-- VSCode-neovim only: bind "9"/"0" to the flash-vscode extension's commands
-- (mirrors flash.nvim's "9"/"0" in lua/plugins/flash.lua, which only fires in
-- standalone nvim since flash.nvim never receives real keystrokes in VSCode).
-- `vim.g.vscode` is only set when running inside the vscode-neovim extension.
if vim.g.vscode then
  vim.keymap.set("n", "s", function()
    require("vscode").action("flash-vscode.start")
  end, { desc = "Flash (VSCode)" })
  vim.keymap.set("n", "S", function()
    require("vscode").action("flash-vscode.jump.treesitterSelection")
  end, { desc = "Flash Treesitter (VSCode)" })

  -- <leader><leader> (space space) opens VSCode's quick open file browser.
  vim.keymap.set("n", "<leader><leader>", function()
    require("vscode").action("workbench.action.quickOpen")
  end, { desc = "Quick Open (VSCode)" })

  -- <leader>e opens VSCode's file explorer. Defined here in neovim (rather than
  -- as a `space e` chord in VSCode's keybindings.json) so that space only acts
  -- as leader when the editor is focused — a VSCode `space e` chord armed
  -- everywhere makes space hang waiting for a chord in quick open / the
  -- secondary bar, and also swallows the leader before vscode-neovim sees it.
  vim.keymap.set("n", "<leader>e", function()
    require("vscode").action("workbench.view.explorer")
  end, { desc = "Explorer (VSCode)" })
end

-- Replace LazyVim's default <leader>ss (LSP document symbols) with
-- Cmd+Shift+O, so symbol search lives on a single chord instead of a leader
-- sequence. Delete the old mapping first so muscle memory doesn't linger.
pcall(vim.keymap.del, "n", "<leader>ss")
vim.keymap.set("n", "<D-S-o>", function()
  Snacks.picker.lsp_symbols()
end, { desc = "Goto Symbol" })

local ok, wk = pcall(require, "which-key")
if ok then
  wk.add({ { "<leader>a", group = "action", mode = { "n", "x" } } })
end
