-- General settings
require 'settings'
-- Colorscheme
vim.cmd [[colorscheme gruvbox]]
vim.o.background = 'dark'

-- You can configure highlights by doing something like:
vim.cmd [[hi Comment gui=none]]

-- Auto commands
require 'cmds'

-- Lsp stuff
require 'lsp'

-- Keymaps
require 'mappings'
