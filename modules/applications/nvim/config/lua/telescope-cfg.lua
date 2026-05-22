require 'telescope'.setup {
        defaults = {
                sorting_strategy = 'descending',
                path_display     = "truncate",
        },
        pickers  = {
                man_pages = {
                        sections = { 'ALL' },
                },
        },
}

require 'telescope'.load_extension  'ui-select'
require 'telescope'.load_extension  'fzf'

local nmap = function (lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
local tl = require 'telescope.builtin'

-- Telescope misc
nmap('<leader>q',  tl.quickfix,   'Quickfix List [Telescope]')
nmap('<leader>ff', tl.find_files, 'Find Files [Telescope]')
nmap('<leader>fb', tl.buffers,    'List Buffers [Telescope]')
nmap('<leader>fg', tl.live_grep,  'Grep Workspace [Telescope]')
nmap('<leader>fh', tl.help_tags,  'Help Tags [Telescope]')
nmap('<leader>fk', tl.keymaps,    'Keymaps [Telescope]')
nmap('<leader>fm', tl.man_pages,  'Man Pages [Telescope]')
nmap('<leader>fr', tl.resume,     'Resume (previous search) [Telescope]')
nmap('<leader>fp', tl.builtin,    'Builtin Pickers [Telescope]')
nmap('<leader>ft', tl.treesitter, 'Treesitter [Telescope]')

-- Telescope git
nmap('<leader>gb', tl.git_bcommits, 'Git Buffer Commits [Telescope]')
nmap('<leader>gc', tl.git_commits,  'Git Commits [Telescope]')
nmap('<leader>gB', tl.git_branches, 'Git Branches [Telescope]')
nmap('<leader>gs', tl.git_status,   'Git Status [Telescope]')
nmap('<leader>gf', tl.git_files,    'Git Files [Telescope]')
nmap('<leader>gS', tl.git_files,    'Git Stash [Telescope]')
