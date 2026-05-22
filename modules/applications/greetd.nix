{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.greetd;
  inherit (config.machine) sessionWrapper;
in
{
  options.machine.greetd.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = sessionWrapper != null;
        message = "Trying to build a desktop environment but no session wrapper for greetd has been defined.";
      }
    ];

    services.greetd = {
      enable = true;
      settings = {
        terminal = {
          vt = 1;
          switch = false;
        };
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Start-Graphical-Session";
          user = "greeter";
        };
      };
      useTextGreeter = true;
    };

    environment.systemPackages = [ sessionWrapper ];
  };
}
