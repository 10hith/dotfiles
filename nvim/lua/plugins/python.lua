return {
  -- Enable LazyVim's Python language extra:
  -- LSP (basedpyright, selected via vim.g.lazyvim_python_lsp in config/options.lua),
  -- ruff (lint/format), debugpy + nvim-dap-python, neotest-python, venv-selector,
  -- and python treesitter parsers. Mason auto-installs the tools on first launch.
  { import = "lazyvim.plugins.extras.lang.python" },
}
