{ pkgs }:
{
  luaFiles = [ ./init.lua ];
  aliases = [
    "vi"
    "vim"
  ];
  extraBinPath = [
    pkgs.ripgrep
    pkgs.fd
    pkgs.wl-clipboard
  ];
  plugins =
    let
      p = pkgs.vimPlugins;
      t = pkgs.vimPlugins.nvim-treesitter.grammarPlugins;
    in
    {
      start = [
        p.luasnip
        p.friendly-snippets
        p.nvim-web-devicons
        p.which-key
        p.mini-nvim
        p.telescope-fzf-native-nvim
        p.telescope-ui-select-nvim
        p.telescope-nvim
        p.nvim-treesitter.withAllGrammars
      ];
      opt = [
        p.vimtex
        p.fidget-nvim
        p.otter-nvim
        p.gruvbox-nvim

        p.blink-cmp
        p.conform-nvim
        p.nvim-lint
      ];
    };
}
