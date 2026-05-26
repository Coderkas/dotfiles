---@param client vim.lsp.Client
---@param bufnr integer
local function default_on_attach(client, bufnr)
        local nmap = function (lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end

        local lsp_map = function (method, lhs, rhs, desc)
                if not client:supports_method(method) then return end
                nmap(lhs, rhs, 'LSP ' .. desc)
        end

        -- LSP bindings
        lsp_map('textDocument/hover',       'K',          vim.lsp.buf.hover,       'Trigger hover')
        lsp_map('textDocument/rename',      '<leader>ln', vim.lsp.buf.rename,      'Rename symbol')
        lsp_map('textDocument/codeAction',  '<leader>la', vim.lsp.buf.code_action, 'Code action')
        lsp_map('textDocument/declaration', '<leader>lD', vim.lsp.buf.declaration, 'Declaration')

        local lspb = vim.lsp.buf
        local list_workspaces = function () vim.notify(vim.inspect(lspb.list_workspace_folders())) end
        lsp_map('workspace/workspaceFolders', '<leader>lwa', lspb.add_workspace_folder,    'Add Workspace Folder')
        lsp_map('workspace/workspaceFolders', '<leader>lwr', lspb.remove_workspace_folder, 'Remove Workspace Folder')
        lsp_map('workspace/workspaceFolders', '<leader>lwl', list_workspaces,              'List Workspace Folders')

        -- LSP bindings with telescope
        local tl = require 'telescope.builtin'
        lsp_map('textDocument/definition',     '<leader>ld',  tl.lsp_definitions,       'Definitions [Telescope]')
        lsp_map('textDocument/typeDefinition', '<leader>lt',  tl.lsp_type_definitions,  'Type Definitions [Telescope]')
        lsp_map('textDocument/implementation', '<leader>li',  tl.lsp_implementations,   'Implementations [Telescope]')
        lsp_map('textDocument/references',     '<leader>lr',  tl.lsp_references,        'References [Telescope]')
        lsp_map('textDocument/documentSymbol', '<leader>ls',  tl.lsp_document_symbols,  'Document Symbols [Telescope]')
        lsp_map('workspace/symbol',            '<leader>lws', tl.lsp_workspace_symbols, 'Workspace Symbols [Telescope]')

        if client:supports_method 'textDocument/codeLens' then
                vim.lsp.codelens.enable(true, { bufnr = bufnr })
        end

        if client:supports_method 'textDocument/inlayHint' then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
        -- Diagnostics
        nmap('<leader>e',  vim.diagnostic.open_float, 'Open diagnostic float')
        nmap('<leader>dn', vim.diagnostic.goto_next,  'Go to next diagnostic')
        nmap('<leader>dp', vim.diagnostic.goto_prev,  'Go to previous diagnostic')
        nmap('<leader>dl', tl.diagnostics,             'List diagnostics [Telescope]')
end

---@type vim.lsp.Config
local default_config = {
        root_markers = { '.git' },
        on_attach    = default_on_attach,
}

vim.api.nvim_create_user_command('LspInfo', ':checkhealth vim.lsp', { desc = 'Show vim.lsp health' })
vim.api.nvim_create_user_command(
        'LspLog',
        function () vim.cmd('tabnew ' .. vim.lsp.log.get_filename()) end,
        { desc = 'Show vim.lsp health' }
)

vim.lsp.config('*', default_config)

vim.lsp.enable { 'bashls', 'clangd', 'gopls', 'emmylua_ls', 'nil', 'nixd', 'ols', 'rust_analyzer', 'zuban' }

vim.lsp.log.set_level 'ERROR'
