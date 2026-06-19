{
  config,
  lib,
  ...
}:
let
  cfg = config.machine.gnome-keyring;
in
{
  options.machine.gnome-keyring.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.gnome-keyring = {
      description = "GNOME Keyring";
      partOf = [ "graphical-session-pre.target" ];
      wantedBy = [ "graphical-session-pre.target" ];
      serviceConfig = {
        ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --replace";
        Restart = "on-failure";
      };
      unitConfig.ConditionUser = "!greeter";
    };

    programs.seahorse.enable = true;

    services.gnome.gnome-keyring.enable = true;

    security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
  };
}
