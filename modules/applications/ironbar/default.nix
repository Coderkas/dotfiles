{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.ironbar;
  inherit (config.machine) owner theme desktop;

  ironbar-pkg = pkgs.ironbar.override {
    features = [
      "cli"
      "ipc"
      "config+toml"
      "battery"
      "bindmode+all"
      "bluetooth"
      "cairo"
      "clipboard"
      "clock"
      "custom"
      "focused"
      "keyboard"
      "label"
      "launcher"
      "menu"
      "music+all"
      "network_manager"
      "notifications"
      "script"
      "sys_info"
      "tray"
      "workspaces+all"
      "volume"
      "extras"
    ];
  };
in
{
  options.machine.ironbar.enable = lib.mkEnableOption "Enable ironbar as taskbar";

  config = lib.mkIf (cfg.enable || desktop.bar == "ironbar") {
    hjem.users.${owner}.xdg.config.files = {
      "ironbar/config.toml".text = /* toml */ ''
        [monitors.${desktop.primaryMonitor}]
        position = "top"
        height = 30
        icon_theme = "${theme.icons}"
        [[monitors.${desktop.primaryMonitor}.start]]
        type = "battery"
        show_if = "ls /sys/class/power_supply/ | grep --quiet '^BAT'"
        [[monitors.${desktop.primaryMonitor}.start]]
        type = "workspaces"
        favorites = [ "1", "2", "3", "4", "5", "6" ]
        all_monitors = true
        hidden = [ "special:special" ]
        [monitors.${desktop.primaryMonitor}.start.name_map]
        1 = "一"
        2 = "二"
        3 = "三"
        4 = "四"
        5 = "五"
        6 = "六"
        7 = "七"
        8 = "八"
        9 = "九"
        [[monitors.${desktop.primaryMonitor}.center]]
        type = "focused"
        icon_size = 16
        [[monitors.${desktop.primaryMonitor}.end]]
        type = "network_manager"
        [[monitors.${desktop.primaryMonitor}.end]]
        type = "volume"
        [[monitors.${desktop.primaryMonitor}.end]]
        type = "tray"
        [[monitors.${desktop.primaryMonitor}.end]]
        type = "clock"
        format = "%H:%M | %d.%m.%Y"
      '';
      "ironbar/style.css".source = ./style.css;
    };

    systemd.user.services.ironbar-daemon = {
      description = "Ironbar service";
      environment = {
        IRONBAR_LOG = "error";
        IRONBAR_FILE_LOG = "error";
      };
      after = [ "graphical-session.target" ];
      before = [ "tray.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      serviceConfig = {
        Type = "exec";
        Slice = "session.slice";
        ExecStart = lib.getExe ironbar-pkg;
      };
    };

    environment.systemPackages = [
      ironbar-pkg
    ];
  };
}
