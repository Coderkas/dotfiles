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

  # desktop portal stuff
  # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  programs = {
    # Hyprland
    hyprland = {
      enable = true;
      package = hypr-pkgs.land;
      portalPackage = hypr-pkgs.portal;
    };

    dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "Gruvbox-Dark";
              icon-theme = "Gruvbox-Plus-Dark";
            };
          };
        }
      ];
    };
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
    pipewire = {
      enable = true;
      alsa.enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

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
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
    enableAllFirmware = true;
  };

  security = {
    pam.services.greetd.enableGnomeKeyring = true;
    pam.services.hyprlock = { };
  };

  environment.systemPackages = [
    # Desktop environment
    pkgs.xdg-utils
    pkgs.wayfreeze
    pkgs.grim
    pkgs.slurp
    pkgs.tesseract
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.wl-clipboard
    pkgs.via

    pkgs.kdePackages.okular

    # Change monitor config
    pkgs.xorg.xrandr
    pkgs.wlr-randr
    # Event viewer
    pkgs.wev
    pkgs.xorg.xev
  ];
}
