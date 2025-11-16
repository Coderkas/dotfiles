{ config, lib, ... }:
let
  cfg = config.machine.syncthing;
  inherit (config.machine) owner;
in
{
  options.machine.syncthing.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.enableDesktop;
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      group = "users";
      user = owner;
      dataDir = "/home/${owner}/Syncthing";
      configDir = "/home/${owner}/Syncthing/conf";
    };
  };
}
