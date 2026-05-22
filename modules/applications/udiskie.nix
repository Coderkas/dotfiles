{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.udiskie;
  inherit (config.machine) owner;
in
{
  options.machine.udiskie.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."udiskie/config.yml".text = ''
      program_options:
        automount: true
        notify: true
        tray: auto
    '';

    systemd.user.services.udiskie = {
      description = "udiskie mount daemon";
      after = [ "tray.target" ];
      partOf = [ "tray.target" ];
      wantedBy = [ "tray.target" ];
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = "${pkgs.udiskie}/bin/udiskie --appindicator";
      };
    };

    services.udisks2.enable = true;

    environment.systemPackages = [ pkgs.udiskie ];
  };
}
