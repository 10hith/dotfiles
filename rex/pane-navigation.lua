-- State is stored outside the Lua VM so marks survive config reloads.
return function(state_path)
  local function read_state()
    local file = io.open(state_path, "r")
    if not file then return { version = 2, sessions = {}, marks = {} } end
    local contents = file:read("*a")
    file:close()
    local state, err = rex.json.decode(contents)
    if type(state) ~= "table" or (state.version ~= 1 and state.version ~= 2)
        or type(state.sessions) ~= "table" then
      error("Cannot read pane navigation state: " .. tostring(err or "invalid format"), 0)
    end
    if state.version == 1 then
      state.version, state.marks = 2, {}
      for session_id, entry in pairs(state.sessions) do
        for mark, block_id in pairs(entry.marks or {}) do
          state.marks[mark] = { session_id = session_id, block_id = block_id }
        end
        entry.marks = nil
      end
      return state, true
    end
    if type(state.marks) ~= "table" then error("Invalid pane marks state", 0) end
    return state
  end

  local function write_state(state)
    local encoded, encode_err = rex.json.encode(state)
    if not encoded then error(encode_err, 0) end
    -- State updates do not yield; rename keeps readers from seeing partial JSON.
    local file, open_err = io.open(state_path .. ".tmp", "w")
    if not file then error(open_err, 0) end
    local written, write_err = file:write(encoded, "\n")
    local closed, close_err = file:close()
    if not written or not closed then error(write_err or close_err, 0) end
    local renamed, rename_err = os.rename(state_path .. ".tmp", state_path)
    if not renamed then error(rename_err, 0) end
  end

  local function mark_signature(state)
    local names = {}
    for mark in pairs(state.marks) do
      if mark:match("^[a-zA-Z]$") then names[#names + 1] = mark end
    end
    table.sort(names)
    return table.concat(names)
  end

  -- Rex builds mode hints from the bindings loaded in its keymap.
  local configured_marks = read_state()
  local configured_mark_signature = mark_signature(configured_marks)

  local function panes_in(view)
    local live, current = {}, nil
    for _, window in ipairs(view.windows or {}) do
      if window.window_id == view.active_window_id then current = window.focused_block_id end
      for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
          live[block.block_id] = {
            layer_id = layer.layer_id, state = layer.state, window_id = window.window_id,
          }
        end
      end
    end
    return live, current
  end

  local function remember(view, reset_revision)
    if type(view.session_id) ~= "string" or type(view.revision) ~= "number" then
      error("Pane navigation requires a session view", 0)
    end
    local state, migrated = read_state()
    local entry = state.sessions[view.session_id] or { history = {} }
    local live, current = panes_in(view)
    -- Events can arrive out of order, and actions may have already recorded a newer view.
    if not reset_revision and entry.revision and view.revision <= entry.revision then
      if migrated then write_state(state) end
      return state, entry, live, current
    end
    local history, seen = {}, {}
    if current and live[current] then
      history[1], seen[current] = current, true
    end
    for _, block_id in ipairs(entry.history) do
      if live[block_id] and not seen[block_id] then
        history[#history + 1], seen[block_id] = block_id, true
      end
    end
    entry.history, entry.revision = history, view.revision
    for mark, target in pairs(state.marks) do
      if target.session_id == view.session_id and not live[target.block_id] then
        state.marks[mark] = nil
      end
    end
    state.sessions[view.session_id] = entry
    write_state(state)
    return state, entry, live, current
  end

  local function session_view(ctx)
    if not ctx.session_id then error("Open a Rex session before using pane marks", 0) end
    local view, err = rex.session.view{}
    if not view then error(err, 0) end
    return view
  end

  local function validate_mark(mark)
    if not mark:match("^[a-zA-Z]$") then error("Use a letter from a-z or A-Z for a pane mark", 0) end
  end

  local function focus_pane(ctx, view, live, block_id)
    local layer = live[block_id]
    if not layer then error("That pane is no longer open", 0) end
    local result, err
    if layer.state == "minimized" then
      result, err = rex.session.set_layer_state{
        session_id = view.session_id,
        layer_id = layer.layer_id, state = "normal", focus = true,
      }
      if not result then error(err, 0) end
    end
    -- A floating layer may contain several panes; focus the exact marked pane.
    result, err = rex.session.focus_block{ session_id = view.session_id, block_id = block_id }
    if not result then error(err, 0) end
    local focused, view_err = rex.session.view{ session_id = view.session_id }
    if not focused then error(view_err, 0) end
    -- Record immediately so two quick ;o presses reliably toggle back and forth.
    remember(focused)
    -- Server focus alone does not change the tab/workspace displayed by Rex.app.
    if ctx.client_id then
      rex.client.queue("session.select", {
        session_id = view.session_id, window_id = layer.window_id,
      })
    end
    return { session_id = view.session_id, window_id = layer.window_id, block_id = block_id }
  end

  -- The event listener uses this action as the single writer for navigation state.
  rex.action{
    name = "record_pane_navigation",
    title = "Record Pane Navigation",
    args = { view = "object?", reset_revision = "boolean?", removed_session_id = "string?" },
    run = function(ctx, args)
      if args.removed_session_id then
        local state = read_state()
        state.sessions[args.removed_session_id] = nil
        for mark, target in pairs(state.marks) do
          if target.session_id == args.removed_session_id then state.marks[mark] = nil end
        end
        write_state(state)
      elseif args.view then
        remember(args.view, args.reset_revision)
      else
        error("A session view is required", 0)
      end
      return { refresh_mark_bindings = mark_signature(read_state()) ~= configured_mark_signature }
    end,
  }

  rex.action{
    name = "set_pane_mark",
    title = "Set Pane Mark",
    args = { mark = "string" },
    run = function(ctx, args)
      validate_mark(args.mark)
      local view = session_view(ctx)
      local state, entry, live, current = remember(view)
      local block_id = ctx.block_id or current
      if not block_id or not live[block_id] then error("Focus a pane before setting a mark", 0) end
      state.marks[args.mark] = { session_id = view.session_id, block_id = block_id }
      write_state(state)
      -- Queued actions run after this action returns, so reload cannot interrupt it.
      if ctx.client_id and mark_signature(state) ~= configured_mark_signature then
        rex.client.queue("client.config.reload")
      end
      return { mark = args.mark, block_id = block_id }
    end,
  }

  rex.action{
    name = "jump_pane_mark",
    title = "Jump to Pane Mark",
    args = { mark = "string" },
    run = function(ctx, args)
      validate_mark(args.mark)
      local view = session_view(ctx)
      local state, _, live = remember(view)
      local target = state.marks[args.mark]
      if not target then error("Pane mark " .. args.mark .. " is not set or its pane has closed", 0) end
      if target.session_id ~= view.session_id then
        local attached, attach_err = rex.call("session.attach", { session_id = target.session_id })
        if not attached then error(attach_err, 0) end
        view = attached.view
        remember(view)
        live = panes_in(view)
      end
      return focus_pane(ctx, view, live, target.block_id)
    end,
  }

  rex.action{
    name = "previous_active_pane",
    title = "Jump to Last Active Pane",
    run = function(ctx, args)
      local view = session_view(ctx)
      local _, entry, live = remember(view)
      local block_id = entry.history[2]
      if not block_id then error("No previous pane yet; focus another pane first", 0) end
      return focus_pane(ctx, view, live, block_id)
    end,
  }

  rex.mode("pane_mark_set", { exclusive = true })
  rex.mode("pane_mark_jump", { exclusive = true })
  for code = string.byte("a"), string.byte("z") do
    local letter = string.char(code)
    for _, shifted in ipairs({ false, true }) do
      local key = shifted and ("shift+" .. letter) or letter
      local mark = shifted and letter:upper() or letter
      rex.bind("pane_mark_set/" .. key, "set_pane_mark", { mark = mark })
      if configured_marks.marks[mark] then
        rex.bind("pane_mark_jump/" .. key, "jump_pane_mark", { mark = mark })
      end
    end
  end
  for _, prefix in ipairs({
    "", "pane/", "tab/", "resize/", "move/", "scroll/", "search/", "session/",
    "entersearch/", "renametab/", "renamepane/", "tmux/",
  }) do
    rex.bind(prefix .. ";>m", "client.mode.enter", { name = "pane_mark_set", once = true })
    rex.bind(prefix .. ";>'", "client.mode.enter", { name = "pane_mark_jump", once = true })
    rex.bind(prefix .. ";>o", "previous_active_pane")
  end
end
