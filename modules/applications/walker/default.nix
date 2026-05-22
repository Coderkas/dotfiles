{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.walker;
  primaryRunner = config.machine.desktop.runner.name;
  inherit (config.machine) platform owner;
  inherit (inputs.walker.packages.${platform}) walker;
  inherit (inputs.elephant.packages.${platform}) elephant-with-providers;
in
{
  options.machine.walker.enable = lib.mkEnableOption "Enable walker, elephant and the respective services";

  config = lib.mkIf (cfg.enable || primaryRunner == "walker") {
    machine.desktop.runner.commands = {
      menu = lib.getExe' walker "walker";
      web = "${lib.getExe' walker "walker"} -m websearch";
    };

    hjem.users.${owner}.xdg.config.files = {
      "walker/config.toml".source = ./config/config.toml;
      "elephant/desktopapplications.toml".source = ./config/desktopapplications.toml;
      "elephant/websearch.toml".source = ./config/websearch.toml;
      "elephant/providers".source = "${elephant-with-providers}/lib/elephant/providers";
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
          ExecStart = "${lib.getExe' walker "walker"} --gapplication-service";
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
          ExecStart = "${lib.getExe' elephant-with-providers "elephant"}";
          Restart = "on-failure";
          RestartSec = 1;
          ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
        };

        restartTriggers = [ config.environment.systemPackages ];
      };
    };

    environment.systemPackages = [
      walker
      elephant-with-providers
    ];
  };
}
