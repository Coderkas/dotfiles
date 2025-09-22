{
  config,
  pkgs,
  hypr-pkgs,
  ...
}:
{
  imports = [
    ./programs.nix
    ./inputMethods.nix
  ];

  # Instead of using the default stuff we use our own.
  # This builds a derivation named man-paths, which takes the combined package lists of nixos and home-manager,
  # makes sure to install the man output for them and links all of the content under /share/man of each pkg into the directory of the derivation.
  # Now we have a single man_db.conf instead of one for nixos and .manpath for home.
  documentation.man.man-db.manualPages = pkgs.buildEnv {
    name = "man-paths";
    paths = config.environment.systemPackages ++ config.home-manager.users.lorkas.home.packages;
    pathsToLink = [ "/share/man" ];
    extraOutputsToInstall = [ "man" ];
    ignoreCollisions = true;
  };

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

    dbus.packages = [
      pkgs.gcr
      pkgs.gnome-settings-daemon
    ];
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

    systemPackages = [
      pkgs.signal-desktop
      pkgs.keepassxc
      pkgs.firefox
      pkgs.discord
      pkgs.obsidian
      pkgs.gimp
      pkgs.helvum
      pkgs.gnome-clocks
      pkgs.element-desktop
      pkgs.oculante
      pkgs.via
      # Gnome files with plugin for previewer
      pkgs.nautilus
      pkgs.sushi

      # Desktop environment
      pkgs.xdg-utils
      pkgs.wayfreeze
      pkgs.grim
      pkgs.slurp
      pkgs.tesseract
      pkgs.kdePackages.xwaylandvideobridge
      pkgs.wl-clipboard
      # necessary for some notification stuff
      pkgs.libnotify

      # Change monitor config
      pkgs.xorg.xrandr
      pkgs.wlr-randr
      # Event viewer
      pkgs.wev
      pkgs.xorg.xev
    ];
  };
}
