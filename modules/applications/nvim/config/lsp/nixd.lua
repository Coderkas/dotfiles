---@type vim.lsp.Config
return {
        cmd          = { 'nixd' },
        filetypes    = { 'nix' },
        root_markers = { 'flake.nix', '.git' },
        settings     = {
                nixd = {
                        nixpkgs = {
                                expr = 'import <nixpkgs> { }',
                        },
                        options = {
                                nixos = {
                                        expr =
                                        '(builtins.getFlake (builtins.toString /home/lorkas/dotfiles)).nixosConfigurations.omnissiah.options',
                                },
                        },
                },
        },
}
