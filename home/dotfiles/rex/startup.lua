---@diagnostic disable: undefined-global
-- Run with `rex do` against the local server; leave existing sessions untouched.
local home = os.getenv("HOME")
local sessions, list_err = rex.call("session.list")
if sessions == nil then error(list_err, 0) end

local existing = {}
for _, session in ipairs(sessions.sessions or {}) do
    existing[session.label] = true
end

for _, project in ipairs({
    { name = "dotfiles", directory = home .. "/code/.dotfiles" },
    { name = "mobile", directory = home .. "/work/zcontrol-mobile" },
    { name = "backend", directory = home .. "/work/zcontrol-data-platform" },
}) do
    if not existing[project.name] then
        local created, create_err = rex.call("session.create", {
            label = project.name,
            initial_windows = {
                {
                    layout = rex.layout.block {
                        flavor = "com.superlogical.terminal.shell",
                        options = { cwd = project.directory },
                    },
                },
            },
        })
        if created == nil then error(create_err, 0) end
    end
end
