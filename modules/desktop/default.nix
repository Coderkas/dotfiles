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
  imports = [
    ./anyrun.nix
    ./dunst.nix
    ./rofi.nix
    ./terminal.nix
    ./xdg.nix
    ./input.nix
    ./kitty.nix
    ./ghostty.nix
    ./walker.nix
    ./browser.nix
  ];

  options.machine = {
    enableDesktop = lib.mkEnableOption "";
    runner = {
      name = lib.mkOption {
        type = lib.types.enum [
          "anyrun"
          "rofi"
          "walker"
        ];
      };
      commands = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };
    };
  };

  config = lib.mkIf cfg.enableDesktop {
    hjem.users.${owner}.xdg.config.files = {
      "zathura/zathurarc".text = theme.zathura;
      "mpv/mpv.conf".text = "volume=20";
      "quickshell".source = ./quickshell;
    };

    programs = {
      dconf.enable = true;
      kdeconnect.enable = true;
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
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
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
        scheduler = "scx_bpfland";
      };

      dbus.implementation = "broker";
      devmon.enable = true;
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
      };
      gvfs.enable = true;
    };

    security.pam.services.greetd.enableGnomeKeyring = true;

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland,x11,windows"; # Not adding ",x11,windos" causes issues with easy anti cheat
      };

      systemPackages = [
        pkgs.quickshell
        pkgs.zathura
        (pkgs.mpv.override {
          mpv-unwrapped = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; };
        })
        pkgs.keepassxc
        pkgs.discord
        pkgs.obsidian
        pkgs.gnome-clocks
        pkgs.oculante # image viewer
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
        pkgs.xrandr
        pkgs.wlr-randr

        pkgs.wf-recorder
        pkgs.python3
      ];
    };
  };
}
