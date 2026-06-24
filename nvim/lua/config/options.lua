-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use basedpyright instead of pyright for the lang.python extra.
-- Must be set here (options load before plugins) so the extra reads it.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff" -- default; "ruff_lsp" selects the old LSP

-- Show the file path in a winbar at the top of each window.
-- %= right-aligns, %m shows modified flag, %F shows the full file path.
vim.opt.winbar = "%=%m %F"
