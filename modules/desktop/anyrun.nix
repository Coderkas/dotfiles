{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  anyrun-pkg = pkgs.anyrun.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./anyrun.patch ];
  });
in
{
  config = lib.mkIf (cfg.enableDesktop && cfg.runner.name == "anyrun") {
    hjem.users.${cfg.owner}.xdg.config.files."anyrun".source = ./anyrun;

    machine.runner.commands = ''
      $menu = ${lib.getExe anyrun-pkg} --plugins libapplications.so --plugins libshell.so --plugins librink.so
      $bmenu = ${lib.getExe anyrun-pkg} --plugins libwebsearch.so --plugins libdictionary.so
    '';

    systemd.user.services.anyrun-daemon = {
      after = [ "graphical-session.target" ];
      description = "Anyrun daemon service";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe anyrun-pkg} daemon";
        KillMode = "process";
      };
    };

    environment.systemPackages = [
      anyrun-pkg
      pkgs.anyrun-provider
    ];
  };
}
