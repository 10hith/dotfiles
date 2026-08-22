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

-- JSON nulls decode to vim.NIL (which is truthy); normalize to a display string.
local function str(v)
  if v == nil or v == vim.NIL then
    return "?"
  end
  return tostring(v)
end

-- Find a target herdr agent window. Search order: agents in the current tab,
-- then agents elsewhere in the current workspace, then agents in any
-- workspace. Always returns (at most) the first match in that tier — no
-- picker, since herdr can have many agents across many workspaces.
local function candidate_agents()
  local out = vim.system({ "herdr", "agent", "list" }):wait()
  if out.code ~= 0 then
    return {}
  end
  local ok, decoded = pcall(vim.json.decode, out.stdout)
  if not ok then
    return {}
  end
  local agents = (decoded.result and decoded.result.agents) or {}
  local self_pane = vim.env.HERDR_PANE_ID -- reliably set inside a herdr pane
  local my_tab = vim.env.HERDR_TAB_ID
  local my_workspace = vim.env.HERDR_WORKSPACE_ID

  local function collect(predicate)
    local res = {}
    for _, a in ipairs(agents) do
      if a.pane_id ~= self_pane and predicate(a) then
        res[#res + 1] = a
      end
    end
    return res
  end

  local tier = collect(function(a)
    return my_tab ~= nil and a.tab_id == my_tab
  end)
  if #tier == 0 then
    tier = collect(function(a)
      return my_workspace ~= nil and a.workspace_id == my_workspace
    end)
  end
  if #tier == 0 then
    tier = collect(function()
      return true
    end)
  end
  return tier
end

local function describe(agent)
  return string.format("%s — %s", str(agent.agent), str(agent.terminal_title_stripped))
end

-- Deliver `text` to the agent hosting pane_id. submit => atomically paste +
-- Enter via `agent prompt` and stay in nvim; otherwise bracketed-paste the
-- text (no submit) and focus that agent so you can finish the message there.
-- `pane send-text` does not bracketed-paste on its own — embedded newlines
-- get treated as separate Enter-submitted lines by the shell — so the
-- non-submit path wraps the payload in paste-mode escapes itself.
local function deliver(pane_id, text, submit)
  if submit then
    vim.system({ "herdr", "agent", "prompt", pane_id, text }):wait()
  else
    vim.system({ "herdr", "pane", "send-text", pane_id, "\27[200~" .. text .. "\27[201~" }):wait()
    vim.system({ "herdr", "agent", "focus", pane_id }):wait()
  end
end

local function send_to_pane(l1, l2, submit)
  local text = payload(l1, l2)
  if not vim.env.HERDR_ENV then -- graceful fallback outside herdr
    vim.fn.setreg("+", text)
    vim.notify("Not in herdr — copied to clipboard instead", vim.log.levels.WARN)
    return
  end
  local agents = candidate_agents()
  if #agents == 0 then
    vim.notify("No agent window found", vim.log.levels.WARN)
    return
  end
  local target = agents[1]
  deliver(target.pane_id, text, submit)
  vim.notify("Sent to " .. describe(target), vim.log.levels.INFO)
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
end

local ok, wk = pcall(require, "which-key")
if ok then
  wk.add({ { "<leader>a", group = "action", mode = { "n", "x" } } })
end
