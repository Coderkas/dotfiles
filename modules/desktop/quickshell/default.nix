{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) owner;
in
{
  options.machine.quickshell.enable = lib.mkEnableOption "Enable quickshell as taskbar";

  config = lib.mkIf (cfg.quickshell.enable && !cfg.ironbar.enable) {
    hjem.users.${owner}.xdg.config.files = {
      "quickshell/shell.qml".source = ./shell.qml;
      "quickshell/Style.qml".source = ./Style.qml;
      "quickshell/Workspaces.qml".source = ./Workspaces.qml;
    };

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
