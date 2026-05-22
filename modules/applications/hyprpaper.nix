{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine.hyprpaper;
  inherit (config.machine) owner platform;
  hyprpaper-git = inputs.hyprpaper.packages.${platform}.hyprpaper;
in
{
  options.machine.hyprpaper.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."hypr/hyprpaper.conf".text = ''
      splash = false
      wallpaper {
        monitor =
        path = /home/${owner}/Pictures/AmeIna.png
        fit_mode =
      }
    '';

    systemd.user.services.hyprpaper = {
      description = "Hyprpaper service";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = "${hyprpaper-git}/bin/hyprpaper";
      };
    };

    environment.systemPackages = [ hyprpaper-git ];
  };
}
