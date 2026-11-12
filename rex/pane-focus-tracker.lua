-- Run with rex do --all. Rex does not deliver events to init.lua itself.
local seen = {}

local function record(args)
  local result, err = rex.call("client.action", {
    action = "record_pane_navigation", args = args,
  })
  if not result then error(err, 0) end
  -- Pruning a closed pane can remove a mark. Refresh hints after the action ends.
  if result.result and result.result.refresh_mark_bindings then
    local reloaded, reload_err = rex.call("server.config_reload", {})
    if not reloaded then error(reload_err, 0) end
    for _, diagnostic in ipairs(reloaded.diagnostics or {}) do
      if diagnostic.severity == "error" then error(diagnostic.message, 0) end
    end
  end
end

local function refresh(session_id)
  if not session_id then return end
  local view = rex.session.view{ session_id = session_id }
  -- A queued view event can outlive its session.
  if not view then return end
  record{ view = view, reset_revision = not seen[session_id] }
  seen[session_id] = true
end

local function refresh_all()
  local listed, err = rex.call("session.list")
  if not listed then error(err, 0) end
  for _, session in ipairs(listed.sessions or {}) do refresh(session.session_id) end
end

rex.on("session_view_changed", function(ctx, ev) refresh(ctx.session_id) end)
rex.on("session_created", function(ctx, ev) refresh(ev.session.session_id) end)
rex.on("session_destroyed", function(ctx, ev)
  seen[ev.session_id] = nil
  record{ removed_session_id = ev.session_id }
end)
rex.on("keymap_changed", refresh_all)
refresh_all()
