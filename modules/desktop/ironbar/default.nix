{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) owner theme;
in
{
  options.machine.ironbar.enable = lib.mkEnableOption "Enable ironbar as taskbar";

  config = lib.mkIf (cfg.ironbar.enable && !cfg.quickshell.enable) {
    hjem.users.${owner}.xdg.config.files = {
      "ironbar/config.toml".text = /* toml */ ''
        [monitors.DP-2]
        position = "top"
        height = 30
        icon_theme = "${theme.icons}"
        [[monitors.DP-2.start]]
        type = "battery"
        show_if = "ls /sys/class/power_supply/ | grep --quiet '^BAT'"
        [[monitors.DP-2.start]]
        type = "workspaces"
        favorites = [ "1", "2", "3", "4", "5", "6" ]
        all_monitors = true
        hidden = [ "special:special" ]
        [monitors.DP-2.start.name_map]
        1 = "一"
        2 = "二"
        3 = "三"
        4 = "四"
        5 = "五"
        6 = "六"
        7 = "七"
        8 = "八"
        9 = "九"
        [[monitors.DP-2.center]]
        type = "focused"
        icon_size = 16
        [[monitors.DP-2.end]]
        type = "network_manager"
        [[monitors.DP-2.end]]
        type = "volume"
        [[monitors.DP-2.end]]
        type = "tray"
        [[monitors.DP-2.end]]
        type = "clock"
        format = "%H:%M | %d.%m.%Y"
      '';
      "ironbar/style.css".source = ./style.css;
    };

    systemd.user.services.ironbar-daemon = {
      after = [ "graphical-session.target" ];
      description = "Ironbar service";
      environment = {
        IRONBAR_LOG = "error";
        IRONBAR_FILE_LOG = "error";
      };
      partOf = [
        "graphical-session.target"
        "tray.target"
      ];
      wantedBy = [
        "graphical-session.target"
        "tray.target"
      ];
      path = lib.mkForce [ ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.ironbar}";
      };
    };

    environment.systemPackages = [
      pkgs.ironbar
    ];
  };
}
