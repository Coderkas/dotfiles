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
