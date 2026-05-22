{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine.hyprlock;
  inherit (config.machine) owner platform desktop;
  hyprlock-git = inputs.hyprlock.packages.${platform}.hyprlock;
in
{
  options.machine.hyprlock.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."hypr/hyprlock.conf".text = ''
      background {
        blur_passes=3
        blur_size=8
        path=screenshot
      }

      general {
        hide_cursor=true
      }

      input-field {
        monitor=${desktop.primaryMonitor}
        size=300, 50
        fade_on_empty=false
        font_color=rgb(202, 211, 245)
        inner_color=rgb(91, 96, 120)
        outer_color=rgb(24, 25, 38)
        outline_thickness=5
        placeholder_text=<span foreground="##cad3f5">Password...</span>
        position=0, -80
        shadow_passes=2
      }
    '';

    security.pam.services.hyprlock = { };

    environment.systemPackages = [ hyprlock-git ];
  };
}
