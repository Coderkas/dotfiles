require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup {
  enabled = function()
    return true
  end,
  completion = {
    keyword = { range = 'full' },
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    ghost_text = { enabled = true },
    list = { selection = { preselect = false, auto_insert = false } },
  },
  sources = {
    default = {
      'lsp',
      'path',
      'snippets',
      'buffer',
    },
  },
  snippets = { preset = 'luasnip' },
  signature = { enabled = true },
  keymap = { preset = 'default' },
}
