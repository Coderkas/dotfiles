---type blink.cmp.Config
local blink_cfg = {
        completion = {
                keyword       = { range = 'full' },
                list          = { selection = { preselect = false, auto_insert = false } },
                documentation = {
                        auto_show = true,
                },
                ghost_text    = {
                        enabled = true,
                },
        },
        signature  = {
                enabled = true,
        },
        snippets   = { preset = 'luasnip' },
        sources    = {
                default   = { 'lsp', 'snippets', 'env', 'buffer', 'ripgrep', 'path' },
                providers = {
                        lsp     = {
                                async      = true,
                                timeout_ms = 2000,
                        },
                        buffer  = {
                                async      = true,
                                timeout_ms = 2000,
                                max_items  = 10,
                        },
                        path    = {
                                async      = true,
                                timeout_ms = 500,
                                max_items  = 10,
                        },
                        ripgrep = {
                                name       = 'ripgrep',
                                module     = 'blink-ripgrep',
                                async      = true,
                                timeout_ms = 500,
                                max_items  = 10,
                                opts       = {},
                        },
                        env     = {
                                name   = 'env',
                                module = 'blink-cmp-env',
                                opts   = {},
                        },
                },
        },
}

vim.api.nvim_create_autocmd('VimEnter', {
        group    = 'user-plugin-loading',
        callback = function (_)
                vim.cmd 'packadd blink.cmp'
                vim.cmd 'packadd blink-ripgrep.nvim'
                vim.cmd 'packadd blink-cmp-env'
                require 'blink-cmp'.setup(blink_cfg)

                ---@type lsp.ClientCapabilities
                local default_capabilities = require 'blink.cmp'.get_lsp_capabilities {}
                vim.lsp.config('*', { capabilities = default_capabilities })
        end,
})
