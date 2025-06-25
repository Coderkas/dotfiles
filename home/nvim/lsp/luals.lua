--- ```lua
return {
  on_init = function(client)
    if client.root_dir == '/home/lorkas/dotfiles/home/nvim' then
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = { path = { 'lua/?.lua' } },
        workspace = {
          checkThirdParty = false,
          library = { vim.api.nvim_get_runtime_file('', true), vim.env.VIMRUNTIME },
        },
      })
    end
  end,
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
}
