{
  config,
  lib,
  pkgs,
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
        Type = "dbus";
        BusName = "org.freedesktop.secrets";
        Slice = "session.slice";
        ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground";
        Restart = "on-failure";
      };
    };

    environment.systemPackages = [ pkgs.gnome-keyring ];

    services = {
      gnome.gcr-ssh-agent.enable = true;
      dbus.packages = [
        (pkgs.writeTextFile {
          name = "gkr-portal-dbus-service";
          text = ''
            [D-BUS Service]
            Name=org.freedesktop.impl.portal.Secret
            Exec=/run/wrappers/bin/gnome-keyring-daemon --start --foreground
            SystemdService=gnome-keyring.service
          '';
          destination = "/share/dbus-1/services/org.freedesktop.impl.portal.Secret.service";
        })
        (pkgs.writeTextFile {
          name = "gkr-secrets-dbus-service";
          text = ''
            [D-BUS Service]
            Name=org.freedesktop.secrets
            Exec=/run/wrappers/bin/gnome-keyring-daemon --start --foreground
            SystemdService=gnome-keyring.service
          '';
          destination = "/share/dbus-1/services/org.freedesktop.secrets.service";
        })
        (pkgs.writeTextFile {
          name = "gkr-dbus-service";
          text = ''
            [D-BUS Service]
            Name=org.gnome.keyring
            Exec=/run/wrappers/bin/gnome-keyring-daemon --start --foreground
            SystemdService=gnome-keyring.service
          '';
          destination = "/share/dbus-1/services/org.gnome.keyring.service";
        })
        pkgs.gcr
      ];
    };

    xdg.portal = {
      config.common."org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      extraPortals = [ pkgs.gnome-keyring ];
    };

    programs.seahorse.enable = true;

    security = {
      pam.services = {
        login.enableGnomeKeyring = lib.mkForce false;
        greetd.enableGnomeKeyring = true;
      };

      wrappers.gnome-keyring-daemon = {
        owner = "root";
        group = "root";
        capabilities = "cap_ipc_lock=ep";
        source = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon";
      };
    };
  };
}
