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
        terminalCommand =
          if (config.machine.terminals.primary == "ghostty") then
            "${lib.getExe pkgs.ghostty} +new-window"
          else
            lib.getExe pkgs.kitty;
      in
      {
        "hypr/settings.lua".source = ./settings.lua;
        "hypr/binds.lua".source = ./binds.lua;
        "hypr/rules.lua".source = ./rules.lua;
        "hypr/hyprland.lua".source = ./hyprland.lua;
        "hypr/logger.lua".source = ./logger.lua;

        "hypr/vars.lua".text = /* lua */ ''
          -- hl.on("hyprland.start", function()
          --   hl.exec_cmd("${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all")
          -- end)

          return {
            terminal = "${terminalCommand}",
            mainMonitor = "${cfg.mainMonitor}",
            owner = "${owner}",
            browser = "${inputs.zen-browser.packages.${platform}.twilight}/bin/zen-twilight",
            fileManager = "${lib.getExe pkgs.nautilus}",
            ${runner.commands},
            cmenu = "",
            toggleWvkbd = "${pkgs.procps}/bin/kill --signal 34 $(${pkgs.procps}/bin/pgrep wvkbd-mobintl)",
            host = "${config.machine.name}",
            hyprgrassPath = "${hypkgs.hyprgrass}/lib/libhyprgrass.so"
          }
        '';

        "hypr/hypridle.conf".text = ''
          general {
            after_sleep_cmd=hyprctl dispatch dpms on
            lock_cmd=(pidof hyprlock || hyprlock)
            on_unlock_cmd=xrandr --output ${cfg.mainMonitor} --primary
          }

          listener {
            on-timeout=loginctl lock-session
            timeout=900
          }

          listener {
            on-resume=hyprctl dispatch dpms on
            on-timeout=hyprctl dispatch dpms off
            timeout=1200
          }
        '';

        "hypr/hyprpaper.conf".text = ''
          splash = false
          wallpaper {
            monitor =
            path = /home/${owner}/Pictures/AmeIna.png
            fit_mode =
          }
        '';

        "hypr/hyprlock.conf".text = ''
          background {
            blur_passes=3
            blur_size=8
            path=screenshot
          }

          general {
            hide_cursor=true
          }

          input-field {
            monitor=${cfg.mainMonitor}
            size=300, 50
            fade_on_empty=false
            font_color=rgb(202, 211, 245)
            inner_color=rgb(91, 96, 120)
            outer_color=rgb(24, 25, 38)
            outline_thickness=5
            placeholder_text=<span foreground="##cad3f5">Password...</span>
            position=0, -80
            shadow_passes=2
          }
        '';

        "hypr/screenshot.sh" = {
          source = ./screenshot.sh;
          executable = true;
        };
      };

    systemd = {
      user = {
        services = {
          hyprland = {
            description = "Hyprland compositor service";
            after = [ "graphical-session-pre.target" ];
            before = [ "graphical-session.target" ];
            wants = [
              "graphical-session-pre.target"
              "graphical-session.target"
            ];
            partOf = [ "graphical-session.target" ];
            #wantedBy = [ "graphical-session.target" ];
            path = lib.mkForce [ ];
            serviceConfig = {
              Type = "notify";
              Slice = "session.slice";
              ExecStart = "${hypkgs.hyprland}/bin/Hyprland";
            };
          };
          hypridle = {
            description = "Hypridle service";
            after = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            wantedBy = [ "graphical-session.target" ];
            path = lib.mkForce [ ];
            unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
            serviceConfig = {
              Type = "exec";
              Slice = "session.slice";
              ExecStart = "${hypkgs.hypridle}/bin/hypridle";
            };
          };
          hyprpaper = {
            description = "Hyprpaper service";
            after = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            wantedBy = [ "graphical-session.target" ];
            path = lib.mkForce [ ];
            unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
            serviceConfig = {
              Type = "exec";
              Slice = "session.slice";
              ExecStart = "${hypkgs.hyprpaper}/bin/hyprpaper";
            };
          };
        };
      };
    };

    security.pam.services.hyprlock = { };

    environment = {
      sessionVariables = {
        #  XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };
      systemPackages = [
        hypkgs.hyprlock
        hypkgs.hypridle
        hypkgs.hyprpicker
        hypkgs.hyprpaper
      ];
    };
  };
}
