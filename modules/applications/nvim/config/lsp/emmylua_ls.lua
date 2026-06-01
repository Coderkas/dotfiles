---@type vim.lsp.Config
return {
    cmd = { 'emmylua_ls' },
    filetypes = { 'lua' },
    root_makers = {
        { '.emmyrc.json', '.emmyrc.lua', '.luarc.json', '.luarc.jsonc' },
        { '.stylua.toml', 'stylua.toml' },
        '.git',
    },
    workspace_required = false,
    settings = {
        emmylua = {
            codeLens = { enable = true },
            hint = { enable = true },
            -- Tell the server which Lua you're using (usually LuaJIT, for Neovim).
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim', 'hl' } },
            -- Make the server aware of Neovim runtime files.
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "/run/current-system/sw/share/hypr/stubs",
                    vim.env.XDG_DATA_HOME .. "/nvim/site/pack/" .. vim.env.USER,
                },
            },
        },
    },
    on_init = function(client)
        -- If the workspace has its own emmylua_ls/lua_ls config file, defer to it.
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config'
                and (vim.uv.fs_stat(path .. '/.emmyrc.json') or vim.uv.fs_stat(path .. '/.luarc.json')) then
                client.config.settings = {}
            end
        end
    end,
}
