return {
  root_markers = { '.git', '.obsidian', '.moxide.toml' },
  filetypes = { 'markdown' },
  cmd = { 'markdown-oxide' },
  on_attach = function(args)
    local oxide_client = vim.lsp.get_clients({ bufnr = args.bufnr, name = 'markdown_oxide' })[1]
    vim.api.nvim_buf_create_user_command(0, 'LspToday', function()
      oxide_client.exec_cmd { command = 'jump', arguments = { 'today' } }
    end, {
      desc = "Open today's daily note",
    })
    vim.api.nvim_buf_create_user_command(0, 'LspTomorrow', function()
      oxide_client.exec_cmd { command = 'jump', arguments = { 'tomorrow' } }
    end, {
      desc = "Open tomorrow's daily note",
    })
    vim.api.nvim_buf_create_user_command(0, 'LspYesterday', function()
      oxide_client.exec_cmd { command = 'jump', arguments = { 'yesterday' } }
    end, {
      desc = "Open yesterday's daily note",
    })
  end,
  capabilities = require('blink.cmp').get_lsp_capabilities {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}
