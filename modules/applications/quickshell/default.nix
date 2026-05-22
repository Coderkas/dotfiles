{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.quickshell;
  inherit (config.machine) owner desktop;
in
{
  options.machine.quickshell.enable = lib.mkEnableOption "Enable quickshell as taskbar";

  config = lib.mkIf (cfg.enable || desktop.bar == "quickshell") {
    hjem.users.${owner}.xdg.config.files."quickshell".source = ./config;

    systemd.user.services.quickshell-daemon = {
      description = "Quickshell service";
      after = [ "graphical-session.target" ];
      before = [ "tray.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = "${pkgs.quickshell}/bin/quickshell";
      };
    };

    environment.systemPackages = [
      pkgs.quickshell
    ];
  };
}
