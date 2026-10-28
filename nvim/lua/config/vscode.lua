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

-- Pick named marks and open the selected location in VS Code.
vim.keymap.set("n", "<leader>m", function()
  local items = {}
  local function add_marks(marks)
    for _, mark in ipairs(marks) do
      local name = mark.mark:sub(2)
      if name:match("^[a-zA-Z]$") and mark.pos[2] > 0 then
        local file = mark.file
        if (not file or file == "") and mark.pos[1] > 0 and vim.api.nvim_buf_is_valid(mark.pos[1]) then
          file = vim.api.nvim_buf_get_name(mark.pos[1])
        end
        file = file or ""
        if file == "~" or file:sub(1, 2) == "~/" then
          file = vim.fn.expand("~") .. file:sub(2)
        end
        table.insert(items, {
          label = name,
          description = (file ~= "" and vim.fn.fnamemodify(file, ":~:.") or "[No Name]") .. ":" .. mark.pos[2],
          file = file,
          line = mark.pos[2] - 1,
          bytecol = math.max(mark.pos[3] - 1, 0),
        })
      end
    end
  end
  add_marks(vim.fn.getmarklist())
  add_marks(vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
  if #items == 0 then
    vim.notify("No named marks found")
    return
  end
  require("vscode").eval_async([[
    const editor = vscode.window.activeTextEditor;
    const mark = await vscode.window.showQuickPick(args, {
      placeHolder: 'Select a Neovim mark', matchOnDescription: true
    });
    if (!mark) return;
    const document = mark.file
      ? await vscode.workspace.openTextDocument(vscode.Uri.file(mark.file))
      : editor?.document;
    if (!document) throw new Error('The marked buffer is no longer available');
    const target = await vscode.window.showTextDocument(document);
    const line = Math.min(mark.line, document.lineCount - 1);
    const text = document.lineAt(line).text;
    let bytes = 0, character = 0;
    for (const char of text) {
      const size = new TextEncoder().encode(char).length;
      if (bytes + size > mark.bytecol) break;
      bytes += size;
      character += char.length;
    }
    const position = new vscode.Position(line, character);
    target.selection = new vscode.Selection(position, position);
    target.revealRange(new vscode.Range(position, position), vscode.TextEditorRevealType.InCenterIfOutsideViewport);
  ]], { args = items })
end, { desc = "Marks (VSCode)" })

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

-- <leader>sg mirrors LazyVim's live-grep keymap. Under vscode-neovim there's
-- no telescope, so route it to VSCode's quick text search (floating find in
-- files) instead.
vim.keymap.set("n", "<leader>sg", function()
  require("vscode").action("workbench.action.quickTextSearch")
end, { desc = "Quick Text Search (VSCode)" })

-- <leader>gg mirrors LazyVim's lazygit keymap. Under vscode-neovim there's no
-- terminal lazygit integration, so route it to VSCode's source control view
-- instead.
vim.keymap.set("n", "<leader>gg", function()
  require("vscode").action("workbench.view.scm")
end, { desc = "Source Control (VSCode)" })

-- gr mirrors LazyVim's default LSP "references" keymap. Under vscode-neovim
-- neovim's LSP never attaches (VSCode provides LSP), so LazyVim's gr is inert
-- here — route it to VSCode's "Go to References" peek view instead.
vim.keymap.set("n", "gr", function()
  require("vscode").action("editor.action.referenceSearch.trigger")
end, { desc = "Goto References (VSCode)" })

