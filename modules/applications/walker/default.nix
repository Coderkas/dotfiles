{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.walker;
  inherit (config.machine) owner desktop;
  primaryRunner = desktop.runner.name;
in
{
  options.machine.walker.enable = lib.mkEnableOption "Walker with Elephant";

  config = lib.mkIf (cfg.enable || (desktop.enable && primaryRunner == "walker")) {
    machine.desktop.runner.commands = {
      menu = lib.getExe pkgs.walker;
      web = "${lib.getExe pkgs.walker} -m websearch";
    };

    hjem.users.${owner}.xdg.config.files = {
      "walker/config.toml".source = ./config/config.toml;
      "elephant/desktopapplications.toml".source = ./config/desktopapplications.toml;
      "elephant/websearch.toml".source = ./config/websearch.toml;
    };

    systemd.user.services = {
      walker-daemon = {
        after = [
          "graphical-session.target"
          "elephant-daemon.service"
        ];
        description = "Walker service";
        partOf = [
          "graphical-session.target"
          "elephant-daemon.service"
        ];
        path = lib.mkForce [ ];
        wantedBy = [
          "graphical-session.target"
          "elephant-daemon.service"
        ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.walker} --gapplication-service";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
      elephant-daemon = {
        after = [ "graphical-session.target" ];
        description = "Elephant service";
        partOf = [ "graphical-session.target" ];
        path = lib.mkForce [ ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.elephant;
          Restart = "on-failure";
          RestartSec = 1;
          ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
        };

        restartTriggers = [ config.environment.systemPackages ];
      };
    };

    environment.systemPackages = [
      pkgs.walker
      pkgs.elephant
    ];
  };
}
