{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.easyeffects;
in
{
  options.machine.easyeffects.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
    description = "Enable EasyEffects";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.easyeffects ];

    systemd.user.services.easyeffects = lib.mkIf cfg.enable {
      description = "EasyEffects service";
      after = [ "tray.target" ];
      partOf = [ "tray.target" ];
      wantedBy = [ "tray.target" ];
      path = lib.mkForce [ ];
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = "${lib.getExe pkgs.easyeffects} --service-mode -w";
      };
    };
  };
}
