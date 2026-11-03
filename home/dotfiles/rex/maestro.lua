rex.action {
    name = "run_maestro_workflow",
    title = "Run Maestro workflow…",
    description = "Run a dev workflow with the current app session and a simulator preview.",
    run = function(ctx)
        if not ctx.session_id or not ctx.block_id then
            error("Run Maestro workflow from a project terminal pane.", 0)
        end
        local session, anchor = ctx.session_id, ctx.block_id
        local pane, err = rex.session.describe_block { session_id = session, block_id = anchor }
        if not pane then error(err, 0) end
        local processes, process_err = rex.block.call("com.superlogical.terminal", "process", {
            session_id = session,
            block_id = anchor,
        })
        if not processes then error(process_err, 0) end
        local cwd = (processes.foreground or {}).cwd or (processes.child or {}).cwd
        if not cwd then error("Cannot read the invoking pane's project directory.", 0) end
        local root, root_err = rex.exec({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
        if not root then error(root_err, 0) end
        if not root.ok then error("Cannot find the invoking pane's Git project: " .. root.stderr, 0) end
        local project = root.stdout:gsub("\n$", "")
        local layer, layer_err = rex.session.new_layer {
            session_id = session,
            window_id = pane.block.window_id,
            bounds = { 0.15, 0.15, 0.7, 0.7 },
            focus = true,
            layout = rex.layout.block {
                flavor = "com.superlogical.terminal.shell",
                label = "Run Maestro workflow",
                options = {
                    cwd = project,
                    command = {
                        "python3", os.getenv("HOME") .. "/.config/rex/maestro.py",
                        "--project", project, "--session", session, "--anchor", anchor,
                    },
                },
            },
        }
        if not layer then error(layer_err, 0) end
        return layer
    end,
}
