{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.neovim;
  inherit (config.machine) owner platform;

  vimP = pkgs.vimPlugins;
  startPlugins = [
    vimP.luasnip
    vimP.friendly-snippets
    vimP.nvim-web-devicons
    vimP.which-key-nvim
    vimP.plenary-nvim
    vimP.telescope-fzf-native-nvim
    vimP.telescope-ui-select-nvim
    vimP.telescope-nvim
    vimP.nvim-treesitter.withAllGrammars
  ];
  optPlugins = [
    vimP.vimtex
    vimP.fidget-nvim
    vimP.gruvbox-nvim
    vimP.mini-nvim
    vimP.blink-cmp
    vimP.blink-cmp-env
    vimP.blink-ripgrep-nvim
    vimP.conform-nvim
    vimP.nvim-lint
  ];

  pluginsToPathSet =
    kind: plugins:
    map (plugin: {
      name = "nvim/site/pack/${owner}/${kind}/${plugin.pname}";
      value = {
        source = plugin;
      };
    }) plugins;

  startPaths = pluginsToPathSet "start" startPlugins;
  optPaths = pluginsToPathSet "opt" optPlugins;

  parserPaths = map (tsParser: {
    name = "nvim/site/parser/${tsParser.origGrammar.language}.so";
    value = {
      source = "${tsParser.origGrammar}/parser";
    };
  }) (builtins.attrValues vimP.nvim-treesitter.parsers);

  queryPaths = [
    {
      name = "nvim/site/queries";
      value = {
        source = "${vimP.nvim-treesitter}/runtime/queries";
      };
    }
  ];

  nvimPlugins = builtins.listToAttrs (startPaths ++ optPaths ++ parserPaths ++ queryPaths);
in
{
  options.machine.neovim.enable = lib.mkEnableOption "Enable neovim";

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg = {
      data.files = nvimPlugins;
      config.files."nvim".source = ./config;
    };

    environment = {
      variables.EDITOR = lib.mkForce "nvim";
      sessionVariables = {
        MANPAGER = "nvim +Man!";
        VISUAL = "nvim";
        EDITOR = "nvim";
      };

      systemPackages = [
        pkgs.neovim-unwrapped

        # Runtime deps
        pkgs.tree-sitter
        pkgs.fd
        pkgs.ripgrep

        # Language deps
        pkgs.clang
        pkgs.odin
        pkgs.rustc
        pkgs.cargo
        pkgs.go
        pkgs.python3
        pkgs.luajit

        # LSPs
        pkgs.bash-language-server
        pkgs.clang-tools
        pkgs.gopls
        pkgs.lua-language-server
        inputs.nil.packages.${platform}.default
        pkgs.nixd
        pkgs.ols
        pkgs.rust-analyzer
        pkgs.zuban

        # Linter
        pkgs.clippy
        pkgs.eslint_d
        pkgs.ruff
        pkgs.shellcheck
        pkgs.statix
        pkgs.deadnix
        pkgs.luaPackages.luacheck

        # Formatter
        pkgs.rustfmt
        pkgs.deno
        pkgs.shfmt
        pkgs.nixfmt
      ];
    };
  };
}
