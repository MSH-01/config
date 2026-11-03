local shell = "com.superlogical.terminal.shell"

local function pane(dir, input)
  return rex.layout.block{ flavor = shell, options = { cwd = dir, initial_input = input } }
end

rex.action{
  name  = "querio",
  title = "Open Querio",
  run   = function(ctx, args)
    local dir = os.getenv("HOME") .. "/Developer/querio/webapp"

    local list, err = rex.call("session.list")
    if err ~= nil then error(err, 0) end
    for _, s in ipairs(list.sessions or {}) do
      if s.label == "querio" then
        rex.client.queue("session.select", { session_id = s.session_id })
        return { session_id = s.session_id }
      end
    end

    local created, err = rex.call("session.create", {
      label = "querio",
      initial_windows = {
        {
          window_label = "dev",
          layout = rex.layout.horizontal(0.5,
            pane(dir, "lazygit\r"),
            rex.layout.vertical(0.5, pane(dir, "mise dev:app"), pane(dir, "mise dev:cee"))),
        },
        {
          window_label = "claude",
          layout = rex.layout.horizontal(0.5, pane(dir, "cc\r"), pane(dir, "cc\r")),
        },
      },
    })
    if err ~= nil then error(err, 0) end

    local dev = created.initial_windows[1]
    rex.client.queue("session.select", { session_id = created.session_id, window_id = dev.window_id })
    return { session_id = created.session_id }
  end,
}
