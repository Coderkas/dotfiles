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
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
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

    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
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

  environment.systemPackages = with pkgs; [
    # Desktop environment
    xdg-utils
    wayfreeze
    grim
    slurp
    tesseract
    kdePackages.xwaylandvideobridge
    wl-clipboard
    via

    kdePackages.okular

    # Change monitor config
    xorg.xrandr
    wlr-randr
    # Event viewer
    wev
    xorg.xev
  ];
}
