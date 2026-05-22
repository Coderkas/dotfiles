{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.anyrun;
  primaryRunner = config.machine.desktop.runner.name;
  inherit (config.machine) owner;
  anyrun-pkg = pkgs.anyrun.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./anyrun.patch ];
  });
in
{
  options.machine.anyrun.enable = lib.mkEnableOption "Enable anyrun and its service";

  config = lib.mkIf (cfg.enable || primaryRunner == "anyrun") {
    machine.desktop.runner.commands = {
      menu = "${lib.getExe anyrun-pkg} --plugins libapplications.so --plugins libshell.so --plugins librink.so";
      web = "${lib.getExe anyrun-pkg} --plugins libwebsearch.so --plugins libdictionary.so";
    };

    hjem.users.${owner}.xdg.config.files."anyrun".source = ./config;

    systemd.user.services.anyrun-daemon = {
      description = "Anyrun daemon service";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = "${lib.getExe anyrun-pkg} daemon";
        NotifyAccess = "all";
      };
    };

    environment.systemPackages = [
      anyrun-pkg
      pkgs.anyrun-provider
    ];
  };
}
