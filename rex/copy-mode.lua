-- Applied after the normal Neovim/LazyVim configuration has loaded.
local copy_path = assert(vim.env.REX_COPY_BUFFER, "Missing Rex snapshot path")
local copy_buffer = vim.fn.bufnr(copy_path)
assert(copy_buffer ~= -1, "Rex snapshot buffer was not opened")

-- A detached request survives the viewer closing. The server removes the
-- viewer first, then restores focus without terminal-exit focus overriding it.
vim.api.nvim_create_autocmd("VimLeave", {
  once = true,
  callback = function()
    local session = vim.env.REX_COPY_SOURCE_SESSION
    local source = vim.env.REX_COPY_SOURCE_BLOCK
    local viewer = vim.env.REX_BLOCK
    if session and source and viewer and viewer ~= source then
      vim.fn.jobstart({
        "/Users/basavaraj/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex",
        "-S", "unix:///Users/basavaraj/Library/Application%20Support/rex/server.sock",
        "do", "return_from_vim_copy", "-s", session,
        "source_block_id=" .. source, "viewer_block_id=" .. viewer,
      }, { detach = true })
    end
  end,
})

local function configure_snapshot()
  if not vim.api.nvim_buf_is_valid(copy_buffer) then
    return
  end

  local options = vim.bo[copy_buffer]
  options.modeline = false
  options.swapfile = false
  options.undofile = false
  options.readonly = true
  options.modifiable = false
  options.buftype = "nofile"
  options.bufhidden = "hide"

  -- Use the clipboard provider from the user's configuration.
  vim.keymap.set({ "n", "x" }, "y", '"+y', {
    buffer = copy_buffer, desc = "Yank snapshot to clipboard",
  })
  vim.keymap.set("n", "Y", '"+y$', {
    buffer = copy_buffer, desc = "Yank snapshot line to clipboard",
  })
  vim.keymap.set("n", "q", "<cmd>qall<CR>", {
    buffer = copy_buffer, silent = true, desc = "Return to Rex",
  })
end

local function show_snapshot()
  if vim.api.nvim_buf_is_valid(copy_buffer) then
    configure_snapshot()
    vim.api.nvim_set_current_buf(copy_buffer)
    vim.cmd("normal! G0zb")
  end
end

configure_snapshot()
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function() vim.schedule(show_snapshot) end,
})
-- Reapply buffer-local shortcuts after LazyVim's deferred setup.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function() vim.schedule(show_snapshot) end,
})
