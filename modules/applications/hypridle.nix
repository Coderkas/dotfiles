{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine.hypridle;
  inherit (config.machine) owner platform desktop;
  hypridle-git = inputs.hypridle.packages.${platform}.hypridle;
in
{
  options.machine.hypridle.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."hypr/hypridle.conf".text = ''
      general {
        after_sleep_cmd=hyprctl dispatch dpms on
        lock_cmd=(pidof hyprlock || hyprlock)
        on_unlock_cmd=xrandr --output ${desktop.primaryMonitor} --primary
      }

      listener {
        on-timeout=loginctl lock-session
        timeout=900
      }

      listener {
        on-resume=hyprctl dispatch dpms on
        on-timeout=hyprctl dispatch dpms off
        timeout=1200
      }
    '';

    systemd.user.services.hypridle = {
      description = "Hypridle service";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = "${hypridle-git}/bin/hypridle";
      };
    };

    environment.systemPackages = [ hypridle-git ];
  };
}
