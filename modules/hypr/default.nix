{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.hyprland;
  inherit (config.machine) owner platform runner;
  hypkgs = {
    inherit (inputs.hyprland.packages.${platform}) hyprland xdg-desktop-portal-hyprland;
    inherit (inputs.hyprpicker.packages.${platform}) hyprpicker;
    inherit (inputs.hyprpaper.packages.${platform}) hyprpaper;
    inherit (inputs.hyprlock.packages.${platform}) hyprlock;
    inherit (inputs.hypridle.packages.${platform}) hypridle;
    inherit (inputs.hyprgrass.packages.${platform}) hyprgrass;
  };
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
        package = hypkgs.hyprland;
        portalPackage = hypkgs.xdg-desktop-portal-hyprland;
      };

      hyprlock = {
        enable = true;
        package = hypkgs.hyprlock;
      };
    };

    services.hypridle = {
      enable = true;
      package = hypkgs.hypridle;
    };

    xdg.portal.config.hyprland = {
      default = [
        "gtk"
        "hyprland"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };

    hjem.users.${owner}.xdg.config.files =
      let
        hjemConfigs = config.hjem.users.${owner}.xdg.config.files;
        loadHyprgrass = "exec-once = hyprctl plugin load ${hypkgs.hyprgrass}/lib/libhyprgrass.so";
      in
      {
        "hypr/settings.conf".source = ./settings.conf;
        "hypr/bindings.conf".source = ./bindings.conf;
        "hypr/misc.conf".source = ./misc.conf;
        "hypr/${config.networking.hostName}.conf".source = ./${config.networking.hostName}.conf;
        "hypr/hyprland.conf".text = ''
          exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target
          ${lib.optionalString (config.machine.name == "medusa") loadHyprgrass}

          source = ${hjemConfigs."hypr/vars.conf".source}
          source = ${hjemConfigs."hypr/settings.conf".source}
          source = ${hjemConfigs."hypr/bindings.conf".source}
          source = ${hjemConfigs."hypr/misc.conf".source}
          source = ${hjemConfigs."hypr/${config.networking.hostName}.conf".source}
        '';

        "hypr/vars.conf".text = ''
          $terminal = ${
            if (config.machine.terminals.primary == "ghostty") then
              "${lib.getExe pkgs.ghostty} +new-window"
            else
              "${lib.getExe pkgs.kitty}"
          }
          $mainMonitor = ${cfg.mainMonitor}
          $owner = ${owner}
          ${runner.commands}
          $toggleWvkbd = ${pkgs.procps}/bin/kill --signal 34 $(${pkgs.procps}/bin/pgrep wvkbd-mobintl)
          $browser = ${inputs.zen-browser.packages.${platform}.twilight}/bin/zen-twilight
          $fileManager = ${lib.getExe pkgs.nautilus}
        '';

        "hypr/idle.conf".source = ./hypridle.conf;
        "hypr/hypridle.conf".text = ''
          source = ${hjemConfigs."hypr/vars.conf".source}
          source = ${hjemConfigs."hypr/idle.conf".source}
        '';
        "hypr/paper.conf".source = ./hyprpaper.conf;
        "hypr/hyprpaper.conf".text = ''
          splash = false
          wallpaper {
            monitor =
            path = /home/${owner}/Pictures/AmeIna.png
            fit_mode =
          }
        '';
        "hypr/hyprlock.conf".source = ./hyprlock.conf;

        "hypr/browser.sh" = {
          source = ./browser.sh;
          executable = true;
        };
      };

    systemd = {
      packages = [ hypkgs.hyprpaper ];
      user = {
        services = {
          hyprpaper.wantedBy = [ "graphical-session.target" ];
          hypridle = {
            wantedBy = [ "graphical-session.target" ];
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
        hypkgs.hyprpicker
        hypkgs.hyprpaper
      ];
    };
  };
}
