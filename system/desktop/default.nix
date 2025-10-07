{
  pkgs,
  hypr-pkgs,
  ...
}:
{
  imports = [
    ./programs.nix
    ./inputMethods.nix
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      hypr-pkgs.portal
    ];
  };

  # make tuigreet not obscure the login screen with possible errors
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInputs = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
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

    dbus = {
      packages = [
        pkgs.gcr
        pkgs.gnome-settings-daemon
      ];
      implementation = "broker";
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock = { };
  };

  environment = {
    # desktop portal stuff
    # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
    pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      XDG_SESSION_TYPE = "wayland";
      # not adding ",x11,windos" causes issues with easy anti cheat
      SDL_VIDEODRIVER = "wayland,x11,windows";
      BROWSER = "firefox";
    };
  };
}
