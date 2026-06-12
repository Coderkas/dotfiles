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
  anyrun-prep = pkgs.writeShellScriptBin "anyrun-prep" /* sh */ ''
    if [[ "$1" == "no-term" ]]; then
      echo "systemd-run --user sh -c '$2'"
    else
      echo $2
    fi
  '';
in
{
  options.machine.anyrun.enable = lib.mkEnableOption "Enable anyrun and its service";

  config = lib.mkIf (cfg.enable || primaryRunner == "anyrun") {
    machine.desktop.runner.commands = {
      menu = "${lib.getExe pkgs.anyrun} --plugins libapplications.so --plugins libshell.so --plugins librink.so --plugins libactions.so";
      web = "${lib.getExe pkgs.anyrun} --plugins libwebsearch.so --plugins libdictionary.so";
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
        ExecStart = "${lib.getExe pkgs.anyrun} daemon";
        NotifyAccess = "all";
      };
    };

    environment.systemPackages = [
      anyrun-prep
      pkgs.anyrun
      pkgs.anyrun-provider
    ];
  };
}
