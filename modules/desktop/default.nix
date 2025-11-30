{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) owner theme platform;
in
{
  imports = [
    ./anyrun.nix
    ./dunst.nix
    ./rofi.nix
    ./terminal.nix
    ./xdg.nix
    ./input.nix
  ];

  options.machine.enableDesktop = lib.mkEnableOption "";

  config = lib.mkIf cfg.enableDesktop {
    hjem.users.${owner}.xdg.config.files = {
      "zathura/zathurarc".text = theme.zathura;
      "mpv/mpv.conf".text = "volume=20";
      "quickshell".source = ./quickshell;
    };

    programs = {
      dconf.enable = true;
      firefox.enable = true;
      kdeconnect.enable = true;
      obs-studio.enable = true;
      seahorse.enable = true;
      thunderbird.enable = true;
      java.enable = true;
    };

    systemd = {
      user.services = {
        quickshell-daemon = {
          after = [ "graphical-session.target" ];
          description = "Quickshell service";
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
            ExecStart = "${pkgs.quickshell}/bin/quickshell";
            Restart = "on-failure";
          };
        };
        gnome-keyring = {
          description = "GNOME Keyring";
          partOf = [ "graphical-session-pre.target" ];
          wantedBy = [ "graphical-session-pre.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe' pkgs.gnome-keyring "gnome-keyring-daemon"} --start --foreground";
            Restart = "on-abort";
          };
        };
      };

      # Make tuigreet not obscure the login screen with possible errors
      services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
    };

    services = {
      greetd = {
        enable = true;
        settings = {
          terminal = {
            vt = 1;
            switch = false;
          };
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
            user = "greeter";
          };
        };
      };

      printing = {
        enable = true;
        drivers = [
          # Covers most printers to fix errors
          pkgs.splix
          pkgs.gutenprint
          pkgs.hplip
        ];
      };

      # More scheduling stuff
      scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
      };

      dbus.implementation = "broker";
      devmon.enable = true;
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
      };
      gvfs.enable = true;
    };

    security = {
      pam.services.greetd.enableGnomeKeyring = true;
      rtkit.enable = true; # Something about cpu scheduling and pipewire
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland,x11,windows"; # Not adding ",x11,windos" causes issues with easy anti cheat
        BROWSER = "firefox";
      };

      systemPackages = [
        pkgs.quickshell
        pkgs.zathura
        (pkgs.mpv-unwrapped.wrapper {
          mpv = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; };
        })
        pkgs.anki
        pkgs.rofi
        pkgs.signal-desktop
        pkgs.keepassxc
        pkgs.discord
        pkgs.obsidian
        pkgs.gimp
        pkgs.gnome-clocks
        pkgs.element-desktop
        pkgs.oculante # image viewer
        inputs.zen-browser.packages.${platform}.default

        # Gnome files with plugin for previewer
        (pkgs.nautilus.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [
            pkgs.gst_all_1.gst-plugins-good
            pkgs.gst_all_1.gst-plugins-bad
          ];
        }))

        pkgs.wayfreeze
        pkgs.grim
        pkgs.slurp
        pkgs.tesseract
        pkgs.wl-clipboard
        # Change monitor config
        pkgs.xorg.xrandr
        pkgs.wlr-randr
        # Event viewer
        pkgs.wev
        pkgs.xorg.xev
      ];
    };
  };
}
