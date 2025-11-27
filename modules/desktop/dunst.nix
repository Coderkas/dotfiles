{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.dunst;
  inherit (config.machine) owner theme;
in
{
  options.machine.dunst = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.machine.enableDesktop;
    };
    monitor = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "0";
    };
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."dunst/dunstrc" = {
      generator = lib.generators.toINI { };
      value = {
        global = {
          inherit (cfg) monitor;
          width = "(0,600)";
          height = "(0,200)";
          origin = "top-center";
          corner_radius = 5;
          background = ''"#282828"'';
          foreground = ''"#ebdbb2"'';
          highlight = ''"#fabd2f"'';
          frame_color = ''"#ebdbb2"'';
          frame_width = 1;
          gap_size = 5;
          font = "${theme.font}, Medium 10";
          progress_bar = true;
          icon_theme = ''"${theme.icons}"'';
          enable_recursive_icon_lookup = true;
        };
        urgency_critical = {
          foreground = ''"#cc241d"'';
          highlight = ''"#d65d0e"'';
        };
      };
    };

    services.dbus.packages = [ pkgs.dunst ];

    systemd = {
      packages = [ pkgs.dunst ];
      user.services.dunst = {
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        restartTriggers = [ config.hjem.users.${owner}.xdg.config.files."dunst/dunstrc".source ];
        serviceConfig.ExecReload = "${pkgs.dunst}/bin/dunstctl reload";
        path = lib.mkForce [ ];
      };
    };

    environment.systemPackages = [
      pkgs.dunst
      pkgs.libnotify
    ];
  };
}
