---@type vim.lsp.Config
return {
        cmd          = { 'nil' },
        filetypes    = { 'nix' },
        root_markers = { 'flake.nix', '.git' },
        settings     = {
                ['nil'] = {
                        nix = {
                                flake = {
                                        autoArchive      = true,
                                        nixpkgsInputName = 'nixpkgs',
                                        maxMemoryMB      = 4096,
                                },
                        },
                },
        },
}
