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
    systemd = {
      user.services.gnome-keyring = {
        description = "GNOME Keyring";
        partOf = [ "graphical-session-pre.target" ];
        wantedBy = [ "graphical-session-pre.target" ];
        serviceConfig = {
          ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --replace";
          Restart = "on-failure";
        };
      };

      services.gnome-keyring-daemon = {
        description = "GNOME Keyring before login";
        requires = [ "gnome-keyring-daemon.socket" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground";
          Restart = "on-failure";
        };
      };

      sockets.gnome-keyring-daemon = {
        description = "Gnome Keyring Socket";
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          Priority = 6;
          Backlog = 5;
          ListenStream = "/run/keyring/control";
          DirectoryMode = "0700";
        };
      };
    };

    programs.seahorse.enable = true;

    services.gnome.gnome-keyring.enable = true;
  };
}
