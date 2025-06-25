require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    rust = { 'rustfmt', lsp_format = 'fallback' },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    css = { 'prettierd' },
    html = { 'prettierd' },
    bash = { 'beautysh' },
    nix = { 'nixfmt' },
    python = { 'ruff_format' },
    markdown = { 'prettierd' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    oding = { 'odinfmt' },
    go = { 'gofmt' },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_format = 'fallback',
  },

  formatters = {
    odinfmt = {
      command = 'odinfmt',
      args = { '-stdin' },
      stdin = true,
    },
    rust = {
      options = {
        default_edition = '2024',
      },
    },
  },
}
