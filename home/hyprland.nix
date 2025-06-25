{
  inputs,
  host_name,
  system,
  config,
  ...
}:
{
  xdg.configFile."hypr/modules" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/hypr";
    recursive = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    extraConfig = ''
      # You can split this configuration into multiple files
      # Create your files separately and then link them to this file like this:
      # source = ~/.config/hypr/myColors.conf

      source = ./modules/settings.conf
      source = ./modules/bindings.conf
      source = ./modules/misc.conf
      source = ./modules/${host_name}.conf
    '';
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
          shadow_passes = 2;
        }
      ];
    };
  };

  services = {
    hyprpaper = {
      enable = true;
      package = inputs.hyprpaper.packages.${system}.default;
      settings = {
        ipc = "on";
        preload = [ "/home/lorkas/Pictures/AmeIna.png" ];
        wallpaper = [ ",/home/lorkas/Pictures/AmeIna.png" ];
      };
    };

    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          ignore_dbus_inhibit = false;
          after_sleep_cmd = "hyprctl dispatch dpms on";
          on_unlock_cmd = "xrandr --output DP-2 --primary";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
