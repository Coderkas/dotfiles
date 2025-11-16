{
  config,
  lib,
  hypr-pkgs,
  pkgs,
  ...
}:
let
  cfg = config.machine.hyprland;
  inherit (config.machine) owner;
in
{
  options.machine.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.machine.enableDesktop;
    };
    mainMonitor = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        package = hypr-pkgs.land;
        portalPackage = hypr-pkgs.portal;
      };

      hyprlock = {
        enable = true;
        package = hypr-pkgs.lock;
      };
    };

    services.hypridle = {
      enable = true;
      package = hypr-pkgs.idle;
    };

    xdg.portal = {
      config.hyprland = {
        default = [
          "gtk"
          "hyprland"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      extraPortals = [ hypr-pkgs.portal ];
    };

    hjem.users.${owner}.xdg.config.files =
      let
        hjemConfigs = config.hjem.users.${owner}.xdg.config.files;
      in
      {
        "hypr/settings.conf".source = ./settings.conf;
        "hypr/bindings.conf".source = ./bindings.conf;
        "hypr/misc.conf".source = ./misc.conf;
        "hypr/${config.networking.hostName}.conf".source = ./${config.networking.hostName}.conf;
        "hypr/hyprland.conf".text = ''
          exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target

          source = ${hjemConfigs."hypr/vars.conf".source}
          source = ${hjemConfigs."hypr/settings.conf".source}
          source = ${hjemConfigs."hypr/bindings.conf".source}
          source = ${hjemConfigs."hypr/misc.conf".source}
          source = ${hjemConfigs."hypr/${config.networking.hostName}.conf".source}
        '';

        "hypr/vars.conf".text = ''
          $terminal = ${
            if (config.machine.terminal == "ghostty") then
              "${lib.getExe pkgs.ghostty} +new-window"
            else
              config.machine.terminal
          }
          $mainMonitor = ${cfg.mainMonitor}
          $owner = ${owner}
          $menu = rofi -show combi -combi-modes "window,drun,run" -modes combi
          $cmenu = rofi -modes calc -show calc -no-show-match -no-sort
          $pmenu = rofi -modes power-menu:rofi-power-menu -show power-menu 
        '';

        "hypr/idle.conf".source = ./hypridle.conf;
        "hypr/hypridle.conf".text = ''
          source = ${hjemConfigs."hypr/vars.conf".source}
          source = ${hjemConfigs."hypr/idle.conf".source}
        '';
        "hypr/paper.conf".source = ./hyprpaper.conf;
        "hypr/hyprpaper.conf".text = ''
          source = ${hjemConfigs."hypr/vars.conf".source}
          source = ${hjemConfigs."hypr/paper.conf".source}
        '';
        "hypr/hyprlock.conf".source = ./hyprlock.conf;

        "hypr/browser.sh" = {
          source = ./browser.sh;
          executable = true;
        };
      };

    systemd = {
      packages = [ hypr-pkgs.paper ];
      user = {
        services = {
          hyprpaper = {
            wantedBy = [ "graphical-session.target" ];
            restartTriggers = [ "${./hyprpaper.conf}" ];
          };
          hypridle = {
            wantedBy = [ "graphical-session.target" ];
            restartTriggers = [ "${./hypridle.conf}" ];
            path = lib.mkForce [ ];
          };
        };

        targets.hyprland-session = {
          after = [ "graphical-session-pre.target" ];
          bindsTo = [ "graphical-session.target" ];
          description = "Hyprland compositor session";
          wants = [ "graphical-session-pre.target" ];
        };
      };
    };

    environment = {
      sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };
      systemPackages = [
        hypr-pkgs.picker
        hypr-pkgs.paper
      ];
    };
  };
}
