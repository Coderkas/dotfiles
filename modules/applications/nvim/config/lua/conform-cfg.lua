vim.g.format_on_save_enabled = true

---@type conform.setupOpts
local conform_cfg = {
    default_format_ops = {
        timeout_ms = 500,
        lsp_format = 'fallback',
    },
    formatters = {
        odinfmt = { command = 'odinfmt', args = { '-stdin' } },
        luafmt = { command = 'luafmt', args = { '--stdin' } },
    },
    formatters_by_ft = {
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        odin = { 'odinfmt' },
        rust = { 'rustfmt' },
        go = { 'gofmt' },
        javascript = { 'deno_fmt' },
        typescript = { 'deno_fmt' },
        typescriptreact = { 'deno_fmt' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        lua = { 'luafmt' },
        sh = { 'shfmt' },
        nix = { 'nixfmt' },
        markdown = { 'deno_fmt' },
    },
    format_on_save = function(bufnr)
        if vim.g.format_on_save_enabled then
            return { bufnr = bufnr }
        end
        return nil
    end,
    format_after_save = nil,
    log_level = vim.log.levels.ERROR,
}

vim.api.nvim_create_autocmd("VimEnter", {
    group = "user-plugin-loading",
    callback = function(_)
        vim.cmd 'packadd conform.nvim'
        require 'conform'.setup(conform_cfg)

        vim.api.nvim_create_user_command('ConformToggleAutosave', function()
            vim.g.format_on_save_enabled = not vim.g.format_on_save_enabled
        end, { desc = 'Toggle formatting on file saving with Conform' }
        )

        vim.keymap.set('n', '<leader>lf', require 'conform'.format, { desc = 'LSP Format' })
    end,
})
