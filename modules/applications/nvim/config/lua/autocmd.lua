vim.api.nvim_create_augroup('user-utils',          { clear = false })
vim.api.nvim_create_augroup('user-plugin-loading', { clear = false })

vim.api.nvim_create_autocmd(
        { 'CmdlineEnter', 'CmdlineLeave' },
        {
                group    = 'user-utils',
                desc     = 'Highlight while searching',
                callback = function (_) vim.o.hlsearch = not vim.o.hlsearch end,
        }
)

vim.api.nvim_create_autocmd('FileType', {
        group    = 'user-utils',
        pattern  = '*',
        callback = function (ev)
                local ts_lang = vim.treesitter.language.get_lang(ev.match)
                local parser_loaded, _ = vim.treesitter.language.add(ts_lang)
                if parser_loaded then
                        vim.treesitter.start(ev.buf, ts_lang)
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
        end,
})
