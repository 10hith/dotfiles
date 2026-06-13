-- ── Leader ────────────────────────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Options ───────────────────────────────────────────────────────────────────
vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.termguicolors  = true          -- full color (fixes zellij color bleed)
vim.opt.background     = "dark"
vim.opt.mouse          = "a"
vim.opt.wrap           = false
vim.opt.scrolloff      = 8
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.clipboard      = "unnamedplus" -- system clipboard
vim.opt.undofile       = true          -- persistent undo across sessions
vim.opt.signcolumn     = "yes"         -- avoid jitter when gitsigns/LSP arrive

-- ── Keymaps ───────────────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>",      { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>",       { desc = "Quit" })
map("n", "<Esc>",     "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

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

  -- Treesitter: syntax highlighting. Pinned to master because the main branch
  -- dropped the .setup{} API; staying on master keeps this file flat.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build  = ":TSUpdate",
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
      map("n", "<C-p>",     builtin.find_files, { desc = "Find files" })
      map("n", "@",         builtin.treesitter, { desc = "Symbols in file" })
      map("n", "<leader>g", builtin.live_grep,  { desc = "Live grep" })
    end,
  },
}, {
  change_detection = { notify = false },
})
