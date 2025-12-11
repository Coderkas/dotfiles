{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.terminals;
  inherit (config.machine) owner theme;
in
{
  options.machine.terminals.enableGhostty = lib.mkEnableOption "";

  config = lib.mkIf cfg.enableGhostty {
    hjem.users.${owner}.xdg.config.files."ghostty/config" = {
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
        shell-integration-features = true;
      };
    };

    services.dbus.packages = [ pkgs.ghostty ];

    systemd = {
      packages = [ pkgs.ghostty ];
      user.services."app-com.mitchellh.ghostty" = {
        path = lib.mkForce [ ];
        wantedBy = [ "graphical-session.target" ];
      };
    };

    programs = {
      bash.interactiveShellInit = lib.mkAfter ''
        if test -n "$GHOSTTY_RESOURCES_DIR"; then
          source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
        fi
      '';
      fish.interactiveShellInit = lib.mkAfter ''
        if set -q GHOSTTY_RESOURCES_DIR
          source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        end
      '';
    };

    environment.systemPackages = [
      pkgs.ghostty
    ];
  };
}
