{ config, lib, ... }:
let
  cfg = config.machine.syncthing;
  inherit (config.machine) owner;
in
{
  options.machine.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.machine.enableDesktop;
    };
    devices = lib.mkOption {
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.devices != null;
        message = "syncthing is enable but devices are not specified";
      }
    ];

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      group = "users";
      user = owner;
      dataDir = "/home/${owner}";
      configDir = "/home/${owner}/.config/syncthing";
      databaseDir = "/home/${owner}/.local/state/syncthing";
      overrideFolder = true;
      overrideDevices = true;
      settings = {
        options.urAccepted = -1;
        inherit (cfg) devices;
        folders."Sync" = {
          path = "/home/${owner}/Sync";
          devices = lib.mapAttrsToList (name: _: name) cfg.devices;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
      };
    };
  };
}
