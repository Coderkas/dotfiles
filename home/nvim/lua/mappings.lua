local function is_help_buf()
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == 'help' then
      vim.cmd 'helpc'
      return true
    end
  end
  vim.cmd 'vert h'
  return false
end

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', function()
  local curr = vim.diagnostic.config().virtual_lines
  if not curr then
    vim.diagnostic.config { virtual_lines = { current_line = true } }
  else
    vim.diagnostic.config { virtual_lines = false }
  end
end, { desc = 'Show [e]rror on current line' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Shortcut for Netrw
vim.keymap.set('n', '<leader>pv', '<cmd>:Ex<CR>', { desc = 'Open folder in Netrw' })
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>h', is_help_buf, { desc = 'Open Help' })
