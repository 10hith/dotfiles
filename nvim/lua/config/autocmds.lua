-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-activate a project-local virtualenv on startup.
-- Mimics `source .venv/bin/activate` for the whole Neovim process, so basedpyright,
-- ruff, debugpy, neotest and :terminal all use the project interpreter automatically
-- (no manual `source`, no <leader>cv). Runs once at VimEnter, before any LSP attaches.
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
