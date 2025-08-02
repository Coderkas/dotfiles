local ts = require 'telescope'
ts.setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    manix = {
      manix_args = {},
      cword = false,
    },
  },
}
-- Native nvim ui like code actions use telescope ui
ts.load_extension 'ui-select'
-- Native fzf as fuzzy finder
ts.load_extension 'fzf'
-- Telescope picker for manix, cli for nix manuals/documentation
ts.load_extension 'manix'

local manix_ops = {
  manix_args = { '--source', 'hm_options', '--source', 'nixos_options', '--source', 'nixpkgs_tree' },
}

local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fl', builtin.live_grep, { desc = '[F]ind [L]ive grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[F]ind [O]ldfiles' })

vim.keymap.set('n', '<leader>fn', function()
  require('telescope-manix').search(manix_ops)
end, { desc = '[F]ind ma[N]ix' })

vim.keymap.set('n', '<leader>fgc', builtin.git_commits, { desc = '[F]ind [G]it [C]ommits' })
vim.keymap.set('n', '<leader>fgb', builtin.git_bcommits, { desc = '[F]ind [G]it [B]uffer commits' })
vim.keymap.set('n', '<leader>fgs', builtin.git_status, { desc = '[F]ind [G]it [S]tatus' })

-- Use telescope for lsp stuff
vim.keymap.set('n', '<leader>ti', builtin.lsp_incoming_calls, { desc = '[T]elescope [I]ncoming' })
vim.keymap.set('n', '<leader>to', builtin.lsp_outgoing_calls, { desc = '[T]elescope [O]utgoing' })
vim.keymap.set('n', '<leader>tr', builtin.lsp_references, { desc = '[T]elescope [R]eferences' })
vim.keymap.set('n', '<leader>tI', builtin.lsp_implementations, { desc = '[T]elescope [I]mplementations' })
vim.keymap.set('n', '<leader>td', builtin.lsp_definitions, { desc = '[T]elescope [D]efinitions' })
vim.keymap.set('n', '<leader>tD', builtin.lsp_document_symbols, { desc = '[T]elescope [D]ocument symbols' })
vim.keymap.set('n', '<leader>tW', builtin.lsp_dynamic_workspace_symbols, { desc = '[T]elescope [W]orkspace symbols' })

-- Me grok brain
-- Me copy function from main repo and switch veritcal and horizontal cmd
-- Now help always opens on right side

local help_mappings = function(prompt_bufnr)
  local action_set = require 'telescope.actions.set'
  local action_state = require 'telescope.actions.state'
  local actions = require 'telescope.actions'
  local utils = require 'telescope.utils'
  action_set.select:replace(function(_, cmd)
    local selection = action_state.get_selected_entry()
    if selection == nil then
      utils.__warn_no_selection 'builtin.help_tags'
      return
    end

    actions.close(prompt_bufnr)
    if cmd == 'default' or cmd == 'vertical' then
      vim.cmd('vert help ' .. selection.value)
    elseif cmd == 'horizontal' then
      vim.cmd('help ' .. selection.value)
    elseif cmd == 'tab' then
      vim.cmd('tab help ' .. selection.value)
    end
  end)

  return true
end

vim.keymap.set('n', '<leader>fh', function()
  builtin.help_tags { attach_mappings = help_mappings }
end, { desc = '[F]ind [H]elp tags' })

-- Me grok brain
-- Me do same for man pages
local man_mappings = function(prompt_bufnr)
  local action_set = require 'telescope.actions.set'
  local action_state = require 'telescope.actions.state'
  local actions = require 'telescope.actions'
  local utils = require 'telescope.utils'
  action_set.select:replace(function(_, cmd)
    local selection = action_state.get_selected_entry()
    if selection == nil then
      utils.__warn_no_selection 'builtin.man_pages'
      return
    end

    local args = selection.section .. ' ' .. selection.value
    actions.close(prompt_bufnr)
    if cmd == 'default' or cmd == 'vertical' then
      vim.cmd('vert Man ' .. args)
    elseif cmd == 'horizontal' then
      vim.cmd('Man ' .. args)
    elseif cmd == 'tab' then
      vim.cmd('tab Man ' .. args)
    end
  end)

  return true
end

vim.keymap.set('n', '<leader>fm', function()
  builtin.man_pages { sections = { 'ALL' }, attach_mappings = man_mappings }
end, { desc = '[F]ind [M]an pages' })
