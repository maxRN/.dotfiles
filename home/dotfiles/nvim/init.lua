---get rid of undefined "vim" global warning
---@diagnostic disable: undefined-global
vim.pack.add({
    "https://github.com/nvim-tree/nvim-web-devicons",
})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>so", ":source<CR>")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.winborder = 'rounded'

-- This is so you can use `gf` to open files that are in weird directories.
-- Namely important for frameworks like expo that use file-based routing.
-- This enabels you to open `src/(app)/[customerId]/index.tsx` like normal.
vim.opt.isfname:append({ '(', ')', '[', ']' })

vim.diagnostic.config({
    virtual_text = {
        source = true,
        format = function(diagnostic)
            if diagnostic.user_data and diagnostic.user_data.code then
                return string.format('%s %s', diagnostic.user_data.code, diagnostic.message)
            else
                return diagnostic.message
            end
        end,
    },
    signs = true,
    float = {
        header = 'Diagnostics',
        source = true,
        border = 'rounded',
    }
})

-- AI slop ahead, beware
local function systemlist_checked(cmd)
    local out = vim.fn.systemlist(cmd)
    local code = vim.v.shell_error
    return out, code
end

local function normalize_github_remote(remote)
    -- SSH scp-like: git@github.com:Org/Repo.git
    remote = remote:gsub("^git@github%.com:", "https://github.com/")
    -- SSH URL: ssh://git@github.com/Org/Repo.git
    remote = remote:gsub("^ssh://git@github%.com/", "https://github.com/")
    -- HTTPS: https://github.com/Org/Repo.git
    remote = remote:gsub("%.git$", "")
    return remote
end

vim.api.nvim_create_user_command("GithubLink", function()
    local abs_path = vim.fn.expand("%:p")
    if abs_path == "" then
        return vim.notify("No file.", vim.log.levels.ERROR)
    end

    local root_out, root_code = systemlist_checked("git rev-parse --show-toplevel")
    if root_code ~= 0 or not root_out[1] or root_out[1] == "" then
        return vim.notify("Not inside a git repository.", vim.log.levels.ERROR)
    end
    local repo_root = root_out[1]

    local commit_out, commit_code = systemlist_checked("git rev-parse HEAD")
    if commit_code ~= 0 or not commit_out[1] or commit_out[1] == "" then
        return vim.notify("Failed to get commit hash.", vim.log.levels.ERROR)
    end
    local commit = commit_out[1]

    local remote_out, remote_code = systemlist_checked("git config --get remote.origin.url")
    if remote_code ~= 0 or not remote_out[1] or remote_out[1] == "" then
        return vim.notify("Failed to read remote.origin.url.", vim.log.levels.ERROR)
    end

    local remote = normalize_github_remote(remote_out[1])

    -- ✅ Check AFTER normalization
    if not remote:match("^https://github%.com/") then
        return vim.notify("Not a GitHub repo remote: " .. remote, vim.log.levels.ERROR)
    end

    local rel_path = abs_path:gsub(vim.pesc(repo_root .. "/"), "")
    local line = vim.fn.line(".")
    local url = string.format("%s/blob/%s/%s#L%d", remote, commit, rel_path, line)

    vim.fn.jobstart({ "open", url }, { detach = true }) -- macOS
    vim.notify("Opened: " .. url, vim.log.levels.INFO)
end, {})
