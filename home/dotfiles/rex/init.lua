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
    description = "Pick a project in a floating pane and switch to its session.",
    run         = function(ctx)
        -- rex-sessionizer switches the app in REX_CLIENT, the one that ran this.
        local command = { "rex-sessionizer" }
        if ctx.client_id ~= nil then
            command = { "env", "REX_CLIENT=" .. ctx.client_id, "rex-sessionizer" }
        end
        local layer, err = rex.session.new_layer {
            bounds = { 0.15, 0.15, 0.7, 0.7 },
            focus  = true,
            layout = rex.layout.block {
                flavor  = "com.superlogical.terminal.shell",
                options = { command = command },
            },
        }
        if err ~= nil then error(err, 0) end
        return layer
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
