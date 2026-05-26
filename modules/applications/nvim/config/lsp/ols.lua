---@type vim.lsp.Config
return {
    cmd = { 'ols' },
    filetypes = { 'odin' },
    root_markers = { 'ols.json', '.git', '*.odin' },
    init_options = {
        enable_inlay_hints_params = true,
        enable_inlay_hints_default_params = true,
        enable_inlay_hints_implicit_return = true,
        enable_auto_import = true,
        enable_snippets = true,
        checker_args = "--vet"
    }
}
