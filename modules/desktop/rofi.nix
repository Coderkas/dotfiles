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
  config = lib.mkIf (cfg.enableDesktop && cfg.runner.name == "rofi") {
    hjem.users.${owner}.xdg.config.files = {
      "rofi/config.rasi".text = ''
        configuration {
          cycle: true;
          font: "${theme.font} 10";
          location: 0;
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

    machine.runner.commands = ''
      $menu = ${lib.getExe pkgs.rofi} -modes "combi,calc" -combi-modes "windows,drun,run" -show combi
      $bmenu = ~/.config/hypr/browser.sh
    '';

    environment.systemPackages = [
      (pkgs.rofi.override {
        plugins = [ pkgs.rofi-calc ];
      })
      pkgs.rofi-calc
    ];
  };
}
