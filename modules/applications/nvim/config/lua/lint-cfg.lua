vim.api.nvim_create_autocmd('VimEnter', {
    group = 'user-plugin-loading',
    callback = function(_)
        vim.cmd 'packadd nvim-lint'

        require 'lint'.linters_by_ft = {
            c               = { 'clang-tidy' },
            cpp             = { 'clang-tidy' },
            rust            = { 'clippy' },
            typescript      = { 'eslint_d' },
            typescriptreact = { 'eslint_d' },
            python          = { 'ruff' },
            sh              = { 'shellcheck' },
            bash            = { 'shellcheck' },
            nix             = { 'statix', 'deadnix' },
            lua             = { 'luacheck' },
        }

        local luacheck = require('lint').linters.luacheck
        luacheck.args  = { '--globals hl vim' }
    end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
    group = 'user-utils',
    callback = function(_)
        vim.cmd 'packadd nvim-lint'
        require 'lint'.try_lint()
    end,
})
