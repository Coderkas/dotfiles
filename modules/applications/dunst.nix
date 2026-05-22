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
      default = config.machine.desktop.enable;
    };
    monitor = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = config.machine.desktop.primaryMonitor;
    };
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."dunst/dunstrc" = {
      generator = lib.generators.toINI { };
      value = {
        global = {
          monitor = ''"${cfg.monitor}"'';
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
          font = ''"${theme.font}, Medium 10"'';
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

    systemd = {
      user.services.dunst = {
        description = "Dunst notification daemon";
        documentation = [ "man:dunst(1)" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        restartTriggers = [ config.hjem.users.${owner}.xdg.config.files."dunst/dunstrc".source ];
        path = lib.mkForce [ ];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          Slice = "session.slice";
          ExecStart = "${lib.getExe pkgs.dunst}";
          ExecReload = "${pkgs.dunst}/bin/dunstctl reload";
        };
      };
    };

    environment.systemPackages = [
      pkgs.dunst
      pkgs.libnotify
    ];
  };
}
