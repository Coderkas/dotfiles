{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.terminals;
  inherit (config.machine) owner;
in
{
  options.machine.terminals.primary = lib.mkOption {
    type = lib.types.enum [
      "ghostty"
      "kitty"
    ];
  };

  config = lib.mkIf (cfg.enableKitty || cfg.enableGhostty) {
    assertions = [
      {
        assertion = cfg.primary != null;
        message = "terminals are enabled but no default is set";
      }
    ];

    hjem.users.${owner}.xdg.config.files."xdg-terminals.list".text = ''
      ${lib.optionalString cfg.enableGhostty "com.mitchellh.ghostty.desktop"}
      ${lib.optionalString cfg.enableKitty "kitty.desktop"}
    '';

    environment.systemPackages = [
      pkgs.xdg-terminal-exec
    ];
  };
}
