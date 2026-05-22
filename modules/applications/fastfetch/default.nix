{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.fastfetch;
  inherit (config.machine) owner;
in
{
  options.machine.fastfetch.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
    description = "Enable Fastfetch";
  };
  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."fastfetch/config.jsonc".source = ./config.jsonc;

    environment.systemPackages = [ pkgs.fastfetch ];
  };
}
