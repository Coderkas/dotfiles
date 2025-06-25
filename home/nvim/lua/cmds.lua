-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('my-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'CmdlineEnter', 'CmdlineLeave' }, {
  desc = 'Only highlight while searching',
  group = vim.api.nvim_create_augroup('my-search-highlight', { clear = true }),
  callback = function()
    local curr = vim.o.hlsearch
    vim.o.hlsearch = not curr
  end,
})
