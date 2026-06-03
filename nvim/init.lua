-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Options ───────────────────────────────────────────────────────────────────
vim.opt.number         = true          -- line numbers
vim.opt.relativenumber = false
vim.opt.termguicolors  = true          -- full color support (fixes zellij bleed)
vim.opt.background     = "dark"
vim.opt.mouse          = "a"           -- mouse support
vim.opt.wrap           = false         -- no line wrapping
vim.opt.scrolloff      = 8             -- keep 8 lines visible above/below cursor
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.ignorecase     = true          -- case-insensitive search
vim.opt.smartcase      = true          -- ... unless you type uppercase
vim.opt.clipboard      = "unnamedplus" -- use system clipboard

-- ── Plugins ───────────────────────────────────────────────────────────────────
require("lazy").setup({
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- Treesitter: better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "lua", "python", "javascript", "typescript",
          "json", "yaml", "toml", "markdown", "html", "css",
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },

  -- Telescope: fuzzy file picker + symbol search
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { preview_width = 0.55 },
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files,  { desc = "Find files" })
      vim.keymap.set("n", "@",     builtin.treesitter,  { desc = "Symbols in file" })
      vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
    end,
  },
}, {
  -- Disable lazy.nvim UI notifications on startup
  change_detection = { notify = false },
})
