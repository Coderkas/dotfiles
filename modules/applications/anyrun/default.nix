{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.anyrun;
  inherit (config.machine) owner desktop;
  primaryRunner = desktop.runner.name;
  anyrun-prep = pkgs.writeShellScriptBin "anyrun-prep" /* sh */ ''
    args=("$@")
    if [[ "$1" == "no-term" ]]; then
      echo "systemd-run --user sh -c \"''${args[*]:1}\""
    else
      echo "$2"
    fi
  '';
in
{
  options.machine.anyrun.enable = lib.mkEnableOption "Anyrun";

  config = lib.mkIf (cfg.enable || (desktop.enable && primaryRunner == "anyrun")) {
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
