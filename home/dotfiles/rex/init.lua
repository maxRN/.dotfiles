---@diagnostic disable: undefined-global
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
-- % and " on a US layout
rex.bind("ctrl+a>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+a>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>shift+l", "session.previous")
rex.bind("ctrl+a>r", "client.config.reload")

-- Press Ctrl+A twice to send one to the terminal
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })


for i = 1, 9 do
    rex.bind("ctrl+a>" .. i, "client.tab.goto", { index = i })
end
rex.bind("ctrl+a>j", "pane.focus.down")
rex.bind("ctrl+a>k", "pane.focus.up")
rex.bind("ctrl+a>h", "pane.focus.left")
rex.bind("ctrl+a>l", "pane.focus.right")

rex.action {
    name        = "sessionizer",
    title       = "Open Sessionizer",
    description = "Pick a project in a floating window and switch to its session.",
    ---@diagnostic disable-next-line: unused-local
    run         = function(ctx, args)
        local script = os.getenv("HOME") .. "/.config/rex/sessionizer"
        local layer, err = rex.session.new_layer {
            bounds = { x = 0.2, y = 0.08, w = 0.8, h = 0.40 },
            focus  = true,
            layout = rex.layout.block {
                flavor = "com.superlogical.terminal.shell",
                options = {
                    command = { "/bin/bash", script },
                    shell   = "none",
                    theme   = { background = "#1a1b26", foreground = "#c0caf5" },
                    exit    = { on_completion = false },
                },
            },
        }
        if err ~= nil then error(err, 0) end
        return {
            layer_id = layer.layer_id,
            block_id = layer.block_ids[1],
        }
    end,
}

rex.bind("ctrl+a>f", "sessionizer")
