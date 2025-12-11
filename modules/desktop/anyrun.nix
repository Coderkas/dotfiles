{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine;
in
{
  config = lib.mkIf cfg.enableDesktop {
    hjem.users.${cfg.owner}.xdg.config.files = {
      # move into sub dir, add application.ron
      "anyrun/config.ron".source = ./anyron-config.ron;
      "anyrun/websearch.ron".source = ./anyrun-websearch.ron;
      "anyrun/shell.ron".text = ''
        Config(
          prefix: "",
        )
      '';
      "anyrun/style.css".source = ./anyrun.css;
    };

    systemd.user.services.anyrun-daemon = {
      after = [ "graphical-session.target" ];
      description = "Anyrun daemon service";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe inputs.anyrun.packages.${cfg.platform}.anyrun-with-all-plugins} daemon";
        KillMode = "process";
      };
    };

    environment.systemPackages = [
      inputs.anyrun.packages.${cfg.platform}.anyrun-with-all-plugins
      inputs.anyrun.packages.${cfg.platform}.anyrun-provider
    ];
  };
}
