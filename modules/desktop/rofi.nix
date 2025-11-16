{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) owner theme;
in
{
  config = lib.mkIf cfg.enableDesktop {
    hjem.users.${owner}.xdg.config.files = {
      "rofi/config.rasi".text = ''
        configuration {
          cycle: true;
          drun-exclude-categories: "WebBrowser";
          font: "${theme.font} 10";
          location: 0;
          modes: [ "drun","run","window","combi" ];
          show-icons: true;
          terminal: "${lib.getExe pkgs.ghostty}";
          window-match-fields: "class";
          xoffset: 0;
          yoffset: 0;
        }
        @theme "rofi-theme"

      ''
      + theme.rofi;

      "rofi/rofi-theme.rasi".source = ./rofi-theme.rasi;
    };

    environment.systemPackages = [
      (pkgs.rofi.override {
        plugins = [
          pkgs.rofi-power-menu
          pkgs.rofi-calc
        ];
      })
      pkgs.rofi-power-menu
      pkgs.rofi-calc
      pkgs.sqlite # To make rofi firefox bookmark script work
    ];
  };
}
