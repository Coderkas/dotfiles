{
  pkgs,
  inputs,
  system,
  ...
}:
{

  imports = [
    ./programs.nix
    ./inputMethods.nix
  ];

  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  programs = {
    # Hyprland
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.hyprland;
      portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    };

    dconf.enable = true;
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
      inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland
    ];
  };

  services = {
    # Configure keymap in X11
    xserver = {
      enable = true;
    };

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
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
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

    # Change monitor config
    xorg.xrandr
    wlr-randr
    # Event viewer
    wev
    xorg.xev
  ];
}
