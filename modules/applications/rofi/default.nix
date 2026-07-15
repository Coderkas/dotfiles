{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.rofi;
  inherit (config.machine) owner theme desktop;
  primaryRunner = desktop.runner.name;
in
{
  options.machine.rofi.enable = lib.mkEnableOption "Rofi";

  config = lib.mkIf (cfg.enable || (desktop.enable && primaryRunner == "rofi")) {
    machine.desktop.runner.commands = {
      menu = "${lib.getExe pkgs.rofi} -modes 'combi,calc' -combi-modes 'windows,drun,run' -show combi";
      web = "~/.config/hypr/browser.sh";
    };

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

    environment.systemPackages = [
      (pkgs.rofi.override {
        plugins = [ pkgs.rofi-calc ];
      })
      pkgs.rofi-calc
    ];
  };
}
