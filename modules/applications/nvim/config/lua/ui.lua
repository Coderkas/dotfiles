vim.api.nvim_create_autocmd('VimEnter', {
        group    = 'user-plugin-loading',
        callback = function (_)
                vim.cmd 'packadd gruvbox.nvim'
                vim.cmd 'packadd fidget.nvim'
                require 'gruvbox'.setup()
                vim.cmd 'colorscheme gruvbox'

                require 'fidget'.setup {
                        notification = {
                                override_vim_notify = true,
                        },
                        integration   = {
                                ['nvim-tree']       = { enable = false },
                                ['xcodebuild-nvim'] = { enable = false },
                        },
                }
        end,
}
)
