{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.hyprland;
  inherit (config.machine) owner platform desktop;

  hyprland-git = inputs.hyprland.packages.${platform}.hyprland;
  xdg-desktop-portal-hyprland-git = inputs.hyprland.packages.${platform}.xdg-desktop-portal-hyprland;
in
{
  options.machine.hyprland.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    machine.sessionWrapper = pkgs.writeShellScriptBin "Start-Graphical-Session" ''
      systemctl reset-failed --user
      dbus-update-activation-environment --systemd --all
      systemctl start hyprland.service --user --wait
      systemctl unset-environment --user WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
    '';

    programs.hyprland = {
      enable = true;
      package = hyprland-git;
      portalPackage = xdg-desktop-portal-hyprland-git;
    };

    xdg.portal.config.hyprland = {
      default = [
        "gtk"
        "hyprland"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };

    hjem.users.${owner}.xdg.config.files = {
      "hypr/settings.lua".source = ./config/settings.lua;
      "hypr/binds.lua".source = ./config/binds.lua;
      "hypr/rules.lua".source = ./config/rules.lua;
      "hypr/hyprland.lua".source = ./config/hyprland.lua;
      "hypr/logger.lua".source = ./config/logger.lua;

      "hypr/vars.lua".text = /* lua */ ''
        return {
          terminal = "${desktop.terminal.command}",
          primaryMonitor = "${desktop.primaryMonitor}",
          owner = "${owner}",
          browser = "${desktop.browser.command}",
          fileManager = "${lib.getExe pkgs.nautilus}",
          menu = "${desktop.runner.commands.menu}",
          bmenu = "${desktop.runner.commands.web}",
          cmenu = "",
          toggleWvkbd = "${pkgs.procps}/bin/kill --signal 34 $(${pkgs.procps}/bin/pgrep wvkbd-mobintl)",
          host = "${config.networking.hostName}",
        }
      '';

      "hypr/screenshot.sh" = {
        source = ./config/screenshot.sh;
        executable = true;
      };
    };

    systemd.user.services.hyprland = {
      description = "Hyprland compositor service";
      after = [ "graphical-session-pre.target" ];
      before = [ "graphical-session.target" ];
      wants = [
        "graphical-session-pre.target"
        "graphical-session.target"
      ];
      partOf = [ "graphical-session.target" ];
      path = lib.mkForce [ ];
      serviceConfig = {
        Type = "notify";
        Slice = "session.slice";
        ExecStart = "/run/wrappers/bin/Hyprland";
      };
    };

    environment = {
      sessionVariables = {
        # XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };
    };
  };
}
