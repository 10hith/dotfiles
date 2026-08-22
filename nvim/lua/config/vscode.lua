-- VSCode-neovim only keymaps.
--
-- These bindings only make sense (and only work) when this config runs inside
-- the vscode-neovim extension. `vim.g.vscode` is set by the extension before
-- user config loads, so the guard below evaluates the same way whether this
-- module is required from standalone Neovim (no-op) or VSCode.
--
-- Kept on the neovim side (rather than in VSCode's keybindings.json) on purpose:
-- a VSCode `space e`/`space space` chord armed everywhere makes space hang
-- waiting for a chord in quick open / the secondary bar, and swallows the leader
-- before vscode-neovim sees it. Defining them here means space only acts as
-- leader when the editor is focused.
if not vim.g.vscode then
  return
end

-- Bind "s"/"S" to the flash-vscode extension's commands. This mirrors
-- flash.nvim's "s"/"S" in lua/plugins/flash.lua, which only fires in standalone
-- nvim since flash.nvim never receives real keystrokes under VSCode.
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

-- <leader>e opens VSCode's file explorer.
vim.keymap.set("n", "<leader>e", function()
  require("vscode").action("workbench.view.explorer")
end, { desc = "Explorer (VSCode)" })

