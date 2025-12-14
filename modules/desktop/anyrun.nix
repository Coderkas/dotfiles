{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
in
{
  config = lib.mkIf (cfg.enableDesktop && cfg.runner.name == "anyrun") {
    hjem.users.${cfg.owner}.xdg.config.files."anyrun".source = ./anyrun;

    machine.runner.commands = ''
      $menu = ${lib.getExe pkgs.anyrun} --plugins libapplications.so --plugins libshell.so --plugins librink.so
      $bmenu = ${lib.getExe pkgs.anyrun} --plugins libwebsearch.so --plugins libdictionary.so
    '';

    systemd.user.services.anyrun-daemon = {
      after = [ "graphical-session.target" ];
      description = "Anyrun daemon service";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.anyrun} daemon";
        KillMode = "process";
      };
    };

    environment.systemPackages = [
      pkgs.anyrun
      pkgs.anyrun-provider
    ];
  };
}
