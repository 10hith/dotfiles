-- oil.nvim only makes sense in standalone Neovim: it manages real splits/floats
-- for its buffer, which vscode-neovim can't drive. VSCode already has its own
-- explorer wired up to <leader>e in config/vscode.lua.
if vim.g.vscode then
  return {}
end

return {
  "stevearc/oil.nvim",
  lazy = false,
  ---@module "oil"
  ---@type oil.SetupOpts
  opts = {
    columns = { "icon" },
    keymaps = {
      ["<C-h>"] = false, -- avoid clobbering LazyVim's <C-h> window navigation
      ["<M-h>"] = "actions.select_split",
    },
    view_options = {
      show_hidden = true,
    },
  },
  -- stylua: ignore
  keys = {
    { "-", function() require("oil").open() end, desc = "Open parent directory" },
    { "<leader>-", function() require("oil").toggle_float() end, desc = "Open parent directory (float)" },
  },
}
