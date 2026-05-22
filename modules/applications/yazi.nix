{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.yazi;
in
{
  options.machine.yazi.enable = lib.mkEnableOption "Enable yazi";

  config = {
    programs.yazi = {
      inherit (cfg) enable;
      settings = {
        yazi = {
          mgr.show_hidden = true;
          plugin.prepend_previewers = [
            {
              name = "*.tar*";
              run = "piper --format=url -- ${lib.getExe pkgs.gnutar} tf \"$1\"";
            }
            {
              name = "*.csv";
              run = "piper -- ${lib.getExe pkgs.bat} -p --color=always \"$1\"";
            }
            {
              name = "*.md";
              run = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dark \"$1\"";
            }
          ];
        };
        keymap.mgr.prepend_keymap = [
          {
            on = [
              "f"
              "d"
            ];
            run = "plugin diff";
            desc = "Diff the selected with the hovered file";
          }
          {
            on = "F";
            run = "filter --smart";
            desc = "Filter files";
          }
          {
            on = [
              "g"
              "."
            ];
            run = "cd ~/dotfiles";
            desc = "Go to ~/dotfiles";
          }
          {
            on = [
              "g"
              "s"
            ];
            run = "cd /nix/store";
            desc = "Go to nix store";
          }
        ];
      };
      initLua = pkgs.writeText "yazi-init.lua" ''
        require("full-border"):setup()
      '';
      plugins = {
        inherit (pkgs.yaziPlugins)
          diff
          full-border
          piper
          ;
      };
    };
  };
}
