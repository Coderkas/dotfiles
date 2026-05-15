require 'keymap'

vim.o.clipboard = "unnamedplus"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.foldenable = false
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.incsearch = true
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.showmode = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.tm = 300
vim.o.updatetime = 250
vim.o.winborder = "rounded"
vim.o.wrap = false

require 'gruvbox'.setup()
vim.cmd 'colorscheme gruvbox'

vim.api.nvim_create_augroup('user-utils', {})

vim.api.nvim_create_autocmd(
        { 'CmdlineEnter', 'CmdlineLeave' },
        {
                group    = 'user-utils',
                desc     = 'Highlight while searching',
                callback = function () vim.o.hlsearch = not vim.o.hlsearch end,
        }
)

local add_map = vim.keymap.set
local tl = require 'telescope.builtin'

-- Diagnostics
add_map('n', '<leader>e',  vim.diagnostics.open_float, { desc = 'Open diagnostic float' })
add_map('n', '<leader>dn', vim.diagnostics.goto_next,  { desc = 'Go to next diagnostic' })
add_map('n', '<leader>dp', vim.diagnostics.goto_prev,  { desc = 'Go to previous diagnostic' })
add_map('n', '<leader>dl', tl.diagnostics,             { desc = 'List diagnostics [Telescope]' })

local function list_workspaces() vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders())) end
add_map('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder,    { desc = 'Add folder to workspace' })
add_map('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, { desc = 'Remove folder from workspace' })
add_map('n', '<leader>lwl', list_workspaces,                     { desc = 'List workspace folders' })

-- LSP bindings
add_map('n', 'K',          vim.lsp.buf.hover,       { desc = 'Trigger hover' })
add_map('n', '<leader>ln', vim.lsp.buf.rename,      { desc = 'Rename symbol' })
add_map('n', '<leader>la', vim.lsp.buf.code_action, { desc = 'Code action' })
add_map('n', '<leader>lf', vim.lsp.buf.format,      { desc = 'Format' })

-- LSP bindings with telescope
add_map('n', '<leader>ld',  tl.lsp_definitions,       { desc = 'LSP Definitions [Telescope]' })
add_map('n', '<leader>lt',  tl.lsp_type_definitions,  { desc = 'LSP Type Definitions [Telescope]' })
add_map('n', '<leader>li',  tl.lsp_implementations,   { desc = 'LSP Implementations [Telescope]' })
add_map('n', '<leader>lr',  tl.lsp_references,        { desc = 'LSP References [Telescope]' })
add_map('n', '<leader>ls',  tl.lsp_document_symbols,  { desc = 'LSP Document Symbols [Telescope]' })
add_map('n', '<leader>lws', tl.lsp_workspace_symbols, { desc = 'LSP Workspace Symbols [Telescope]' })

-- Telescope misc
add_map('n', '<leader>q',  tl.quickfix,   { desc = 'Find Files [Telescope]' })
add_map('n', '<leader>ff', tl.find_files, { desc = 'Find Files [Telescope]' })
add_map('n', '<leader>fb', tl.buffers,    { desc = 'List Buffers [Telescope]' })
add_map('n', '<leader>fg', tl.live_grep,  { desc = 'Grep Workspace [Telescope]' })
add_map('n', '<leader>fh', tl.help_tags,  { desc = 'Help Tags [Telescope]' })
add_map('n', '<leader>fk', tl.keymaps,    { desc = 'Keymaps [Telescope]' })
add_map('n', '<leader>fm', tl.man_pages,  { desc = 'Man Pages [Telescope]' })
add_map('n', '<leader>fr', tl.resume,     { desc = 'Resume (previous search) [Telescope]' })
add_map('n', '<leader>fp', tl.builtin,    { desc = 'Builtin Pickers [Telescope]' })
add_map('n', '<leader>ft', tl.treesitter, { desc = 'Treesitter [Telescope]' })

-- Telescope git
add_map('n', '<leader>gb', tl.git_bcommits, { desc = 'Git Buffer Commits [Telescope]' })
add_map('n', '<leader>gc', tl.git_commits,  { desc = 'Git Commits [Telescope]' })
add_map('n', '<leader>gB', tl.git_branches, { desc = 'Git Branches [Telescope]' })
add_map('n', '<leader>gs', tl.git_status,   { desc = 'Git Status [Telescope]' })
add_map('n', '<leader>gf', tl.git_files,    { desc = 'Git Files [Telescope]' })
add_map('n', '<leader>gS', tl.git_files,    { desc = 'Git Stash [Telescope]' })

require 'which-key'.setup {
        preset = 'modern',
        spec   = {
                { '<leader>l',  desc = '+Lsp' },
                { '<leader>f',  desc = '+Telescope' },
                { '<leader>lw', desc = '+Workspace' },
                { '<leader>d',  desc = '+Diagnostics' },
                { '<leader>g',  desc = '+Git' },
        },
}
