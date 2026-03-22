vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

require('lint').linters_by_ft = {
    -- typescript = { 'eslint' },
    -- javascript = { 'eslint' },
    -- typescriptreact = { 'eslint' },
    -- javascriptreact = { 'eslint' },
    python = { 'ruff' },
    rust = { 'clippy' },
}

local pattern = "::([^ ]+) file=(.*),line=(%d+),endLine=(%d+),col=(%d+),endColumn=(%d+),title=(.*)::(.*)"
local severities = {
    ["error"] = vim.diagnostic.severity.ERROR,
    ["warning"] = vim.diagnostic.severity.WARN,
}
local groups = { "severity", "file", "lnum", "end_lnum", "col", "end_col", "code", "message" }
local defaults = { ["source"] = "oxlint" }
local binary_name = "oxlint"

local function file_exists(filepath)
  local f = io.open(filepath, "r")
  if f then
    f:close()
    return true
  else
    return false
  end
end

require('lint').linters.bun_oxlint = {
    cmd = function()
        return "bunx"
        -- local local_binary = vim.fn.fnamemodify("bunx oxlint", ":p")
        -- return vim.loop.fs_stat(local_binary) and local_binary or binary_name
    end,
    stdin = false,
    args = {"oxlint", "--format", "github" },
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults, {}),
}

local function file_contains(path, str)
    if vim.fn.filereadable(path) == 0 then
        return false
    end
    local lines = vim.fn.readfile(path)
    for _, line in ipairs(lines) do
        if string.find(line, str, 1, true) then
            return true
        end
    end
    return false
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function(args)
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        -- for the current filetype
        --     local filepath = vim.api.nvim_buf_get_name(args.buf)
        -- print("File written:", filepath)
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        local uses_bun = false
        if vim.fn.filereadable(git_root .. "/bun.lock") == 1 then
            uses_bun = true
        end
        local uses_oxlint = false
        if file_contains(git_root .. "/package.json", "oxlint") then
            uses_oxlint = true
        end
        if uses_bun and uses_oxlint then
            require("lint").try_lint("bun_oxlint")
            return
        end
        require("lint").try_lint()
    end,
})

