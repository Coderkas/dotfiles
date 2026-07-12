{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.kdeconnect;
  kdeconnect-pkg = pkgs.kdePackages.kdeconnect-kde;
  allowedPorts = [
    {
      from = 1714;
      to = 1764;
    }
  ];
in
{
  options.machine.kdeconnect.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services = {
      kdeconnectd = {
        description = "KDEConnect daemon";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        path = lib.mkForce [ ];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.kde.kdeconnect";
          Slice = "session.slice";
          ExecStart = "${kdeconnect-pkg}/bin/kdeconnectd";
        };
      };
      kdeconnect-indicator = {
        description = "KDEConnect tray indicator";
        after = [
          "tray.target"
          "kdeconnectd.service"
        ];
        partOf = [ "tray.target" ];
        wantedBy = [ "tray.target" ];
        bindsTo = [ "kdeconnectd.service" ];
        path = lib.mkForce [ ];
        serviceConfig = {
          Type = "exec";
          Slice = "session.slice";
          ExecStart = "${kdeconnect-pkg}/bin/kdeconnect-indicator";
        };
      };
    };

    environment.systemPackages = [
      kdeconnect-pkg
    ];

    services.dbus.packages = [
      (pkgs.writeTextFile {
        name = "kdeconnect-dbus-service";
        text = ''
          [D-BUS Service]
          Name=org.kde.kdeconnect
          Exec=${kdeconnect-pkg}/bin/kdeconnectd
          SystemdService=kdeconnectd.service
        '';
        destination = "/share/dbus-1/services/org.kde.kdeconnect.service";
      })
    ];

    networking.firewall = {
      allowedTCPPortRanges = allowedPorts;
      allowedUDPPortRanges = allowedPorts;
    };
  };
}
