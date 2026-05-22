{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.desktop;
in
{
  config = lib.mkIf cfg.enable {
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland,x11,windows"; # Not adding ",x11,windos" causes issues with easy anti cheat
        GDK_BACKEND = "wayland,x11,*";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };

      systemPackages = [
        pkgs.wayfreeze
        pkgs.grim
        pkgs.slurp
        pkgs.tesseract
        pkgs.wl-clipboard

        # Change monitor config
        pkgs.xrandr
        pkgs.wlr-randr
        pkgs.wf-recorder
      ];
    };
  };
}
