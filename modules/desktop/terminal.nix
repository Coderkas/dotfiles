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
  options.machine.terminal = lib.mkOption {
    type = lib.types.enum [
      "ghostty"
      "kitty"
    ];
    default = "ghostty";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.terminal == "ghostty") {
      hjem.users.${owner}.xdg.config.files = {
        "ghostty/config" = {
          generator = lib.generators.toKeyValue {
            listsAsDuplicateKeys = true;
            mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
          };
          value = {
            font-family = theme.font;
            theme = theme.ghostty;
            command = "${lib.getExe pkgs.fish} -l -i";
            window-padding-x = 5;
            window-padding-y = "5,10";
            font-size = 14;
            window-theme = "ghostty";
            gtk-toolbar-style = "flat";
            gtk-titlebar-style = "tabs";
            gtk-wide-tabs = false;
            gtk-tabs-location = "bottom";
            gtk-single-instance = true;
            auto-update = "off";
            quit-after-last-window-closed = false;
            shell-integration = "fish";
          };
        };
        "xdg-terminals.list".text = "com.mitchellh.ghostty.desktop";
      };

      services.dbus.packages = [ pkgs.ghostty ];
      systemd = {
        packages = [ pkgs.ghostty ];
        user.services."app-com.mitchellh.ghostty" = {
          path = lib.mkForce [ ];
          restartTriggers = [ config.hjem.users.${owner}.xdg.config.files."ghostty/config".source ];
          wantedBy = [ "graphical-session.target" ];
        };
      };
      environment.systemPackages = [
        pkgs.ghostty
        pkgs.xdg-terminal-exec
      ];
    })
    (lib.mkIf (cfg.terminal == "kitty") {
      hjem.users.${owner}.xdg.config.files = {
        "kitty/kitty.conf" = {
          generator = lib.generators.toKeyValue {
            listsAsDuplicateKeys = true;
            mkKeyValue = lib.mkKeyValueDefault { } " ";
          };
          value = {
            font_family = theme.font;
            font_size = 14;
            window_margin_width = 10;
            tab_bar_style = "fade";
            tab_fade = 1;
            shell = ".";
            include = "${pkgs.kitty-themes}/share/kitty-themes/themes/${theme.kitty}.conf";
          };
        };
        "xdg-terminals.list".text = "kitty.desktop";
      };

      environment.systemPackages = [
        pkgs.kitty
        pkgs.xdg-terminal-exec
      ];
    })
  ];
}
