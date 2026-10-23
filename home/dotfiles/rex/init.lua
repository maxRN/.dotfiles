---@diagnostic disable: undefined-global

local home = os.getenv("HOME")

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
    args        = { script = "string?" },
    run         = function(ctx, args)
        local script = args.script or os.getenv("HOME") .. "/.config/rex/sessionizer"
        local size, size_err = rex.call("com.superlogical.terminal.size", {
            session_id = ctx.session_id,
            block_id = ctx.block_id,
            args = {},
        })
        if size_err ~= nil then error(size_err, 0) end
        local layer, err = rex.session.new_layer {
            bounds = { x = 0.1, y = 0.08, w = 0.8, h = 0.40 },
            focus  = true,
            layout = rex.layout.block {
                flavor = "com.superlogical.terminal.shell",
                options = {
                    command = { "/bin/bash", script },
                    shell   = "none",
                    size    = {
                        columns = size.columns,
                        rows = size.rows,
                        cell_width_px = size.cell_width_px,
                        cell_height_px = size.cell_height_px,
                    },
                    theme   = { background = "#1a1b26", foreground = "#c0caf5" },
                    exit    = { on_completion = false },
                },
            },
        }
        if err ~= nil then error(err, 0) end
        local _, resize_err = rex.call("com.superlogical.terminal.resize", {
            session_id = ctx.session_id,
            block_id = layer.block_ids[1],
            args = { mode = "release" },
        })
        if resize_err ~= nil then error(resize_err, 0) end
        return {
            layer_id = layer.layer_id,
            block_id = layer.block_ids[1],
        }
    end,
}

rex.bind("ctrl+a>f", "sessionizer")

local function claude_project(name, title, repository)
    rex.action {
        name        = name .. "_claude",
        title       = "Open " .. title .. " with Claude",
        description = "Create a new session in ~/work/" .. repository .. " running Claude.",
        run         = function()
            local created, err = rex.call("session.create", {
                initial_windows = {
                    {
                        layout = rex.layout.block {
                            flavor = "com.superlogical.terminal.shell",
                            options = {
                                cwd = home .. "/work/" .. repository,
                                command = { "claude" },
                            },
                        },
                    },
                },
            })
            if created == nil then error(err, 0) end
            rex.client.queue("session.select", { session_id = created.session_id })
            return created
        end,
    }
end

-- These project checkouts are local to shredder; hide their actions elsewhere.
local hostname = rex.exec({ "hostname", "-s" }, { timeout = 2 })
if hostname and hostname.ok and hostname.stdout:match("^%s*(.-)%s*$") == "shredder" then
    claude_project("backoffice", "Backoffice", "zcontrol-backoffice")
    claude_project("data_platform", "Data Platform", "zcontrol-data-platform")
    claude_project("mobile", "Mobile", "zcontrol-mobile")
    claude_project("zcontrol_backend", "zControl Backend", "zcontrol-backend")
end
