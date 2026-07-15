{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.ghostty;
  inherit (config.machine) owner theme desktop;
  primaryTerminal = desktop.terminal.name;
in
{
  options.machine.ghostty.enable = lib.mkEnableOption "Ghostty";

  config = lib.mkIf (cfg.enable || (desktop.enable && primaryTerminal == "ghostty")) {
    machine.desktop.terminal.command = "${lib.getExe pkgs.ghostty} +new-window";

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
          shell-integration-features = true;
          keybind = [
            "ctrl+shift+w>q=close_tab:this"
            "ctrl+shift+w>h=goto_split:left"
            "ctrl+shift+w>j=goto_split:down"
            "ctrl+shift+w>k=goto_split:up"
            "ctrl+shift+w>l=goto_split:right"
            "ctrl+shift+w>s=new_split:down"
            "ctrl+shift+w>v=new_split:right"
            "ctrl+shift+w>f=toggle_split_zoom"
          ];
        };
      };
      "xdg-terminals.list".text = ''
        com.mitchellh.ghostty.desktop
      '';
    };

    systemd.user.services."app-com.mitchellh.ghostty" = {
      description = "Ghostty";
      after = [
        "graphical-session.target"
        "dbus.socket"
      ];
      requires = [ "dbus.socket" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      serviceConfig = {
        Type = "notify-reload";
        ReloadSignal = "SIGUSR2";
        BusName = "com.mitchellh.ghostty";
        Slice = "session.slice";
        ExecStart = "${lib.getExe pkgs.ghostty} --gtk-single-instance=true --initial-window=false";
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

    services.dbus.packages = [ pkgs.ghostty ];

    environment.systemPackages = [
      pkgs.ghostty
    ];
  };
}
