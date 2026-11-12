local M = {}

local function command(args, input)
  local cmd = { "rex", "--autostart=false" }
  vim.list_extend(cmd, args)
  local result = vim.system(cmd, { text = true, stdin = input }):wait()
  if result.code ~= 0 then
    error(vim.trim(result.stderr or "") ~= "" and vim.trim(result.stderr) or "Rex command failed", 0)
  end
  return result.stdout
end

local function json_command(args)
  return vim.json.decode(command(args))
end

local function agent_name(process)
  for _, field in ipairs({ "name", "script", "argv0" }) do
    local name = vim.fs.basename(process[field] or ""):lower()
    if name == "claude" or name == "claude-code" or name == "claude.js" then return "Claude" end
    if name == "codex" or name == "codex.js" then return "Codex" end
  end
end

local function identify(session, block)
  local process = json_command({ "block", "call", "-s", session, "-b", block, "process" })
  if type(process.foreground) ~= "table" then return nil end
  local name = agent_name(process.foreground)
  if not name then
    local status = json_command({ "block", "call", "-s", session, "-b", block, "program_status" })
    for _, record in ipairs(status.records or {}) do
      -- Status can outlive the agent. Only trust reports from the current process.
      if type(record.owner) == "table" and record.owner.pid == process.foreground.pid
          and record.owner.name == process.foreground.name then
        name = agent_name({ name = record.effective_app or record.app })
        if name then break end
      end
    end
  end
  return name
end

local function candidates()
  local session, source = vim.env.REX_SESSION, vim.env.REX_BLOCK
  local current = json_command({ "session", "inspect", session, "--json" })
  local source_window
  for _, window in ipairs(current.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      for _, block in ipairs(layer.blocks or {}) do
        if block.block_id == source then source_window = window.window_id end
      end
    end
  end
  if not source_window then error("Neovim's Rex pane is no longer in this session", 0) end

  local function collect(view, same_window)
    local found = {}
    for _, window in ipairs(view.windows or {}) do
      if same_window == nil or (window.window_id == source_window) == same_window then
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.blocks or {}) do
            if block.block_id ~= source and block.creator_name == "com.superlogical.terminal" then
              local name = identify(view.session_id, block.block_id)
              if name then
                found[#found + 1] = {
                  session = view.session_id, block = block.block_id,
                  description = string.format("%s — %s / %s / %s [%s]", name,
                    view.label or view.session_id, window.label or window.window_id,
                    block.label or "terminal", block.block_id:sub(-8)),
                }
              end
            end
          end
        end
      end
    end
    return found
  end

  local found = collect(current, true)
  if #found > 0 then return found end
  found = collect(current, false)
  if #found > 0 then return found end
  for _, other in ipairs(json_command({ "session", "ls", "--json" }).sessions or {}) do
    if other.session_id ~= session then
      vim.list_extend(found, collect(json_command({ "session", "inspect", other.session_id, "--json" })))
    end
  end
  return found
end

local function deliver(target, text, submit)
  -- Native paste events let Rex apply the target terminal's bracketed-paste mode.
  command({ "api", "call", "-s", target.session, "block.event", "-" }, vim.json.encode({
    block_id = target.block, event = { type = "paste", payload = { text = text } },
  }))
  if submit then
    command({ "send-key", "-s", target.session, "-b", target.block, "enter" })
  else
    command({ "focus", "-s", target.session, target.block })
    if target.session ~= vim.env.REX_SESSION then
      command({ "do", "session.select", "session_id=" .. target.session })
    end
  end
  vim.notify("Sent to " .. target.description, vim.log.levels.INFO)
end

function M.send(text, submit)
  if not vim.env.REX_SESSION or not vim.env.REX_BLOCK or vim.fn.executable("rex") == 0 then
    vim.fn.setreg("+", text)
    vim.notify("Rex unavailable — copied to clipboard instead", vim.log.levels.WARN)
    return
  end
  local ok, agents = pcall(candidates)
  if not ok then
    vim.notify("Could not discover Rex agents: " .. tostring(agents), vim.log.levels.ERROR)
    return
  end
  if #agents == 0 then
    vim.notify("No Claude or Codex pane found in Rex", vim.log.levels.WARN)
    return
  end
  local function send(target)
    if not target then return end
    local sent, err = pcall(deliver, target, text, submit)
    if not sent then vim.notify("Rex delivery failed: " .. tostring(err), vim.log.levels.ERROR) end
  end
  if #agents == 1 then
    send(agents[1])
  else
    vim.ui.select(agents, {
      prompt = "Send to Rex agent:", format_item = function(agent) return agent.description end,
    }, send)
  end
end

return M
