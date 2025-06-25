-- Enables LSP features if available
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Turn on highlighting of same document symbols after some time
    if client:supports_method 'textDocument/documentHighlight' then
      local highlight_augroup = vim.api.nvim_create_augroup('my.highlight-group', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = args.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = args.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('my.lsp-detach', { clear = true }),
        callback = function(args2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'my.highlight-group', buffer = args2.buf }
        end,
      })
    end
  end,
})

vim.lsp.config('*', {
  root_makers = { '.git' },
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

vim.lsp.enable {
  'luals',
  'nil_ls',
  'bashls',
  'basedpyright',
  'clangd',
  'gopls',
  'markdown_oxide',
  'ltex-ls-plus',
  'texlab',
  'ols',
  'rust_analyzer',
  'ruff',
  'ts_ls',
  'html',
  'cssls',
}
