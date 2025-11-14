{
  hypr-pkgs,
  pkgs,
  ags,
  ...
}:
{
  programs = {
    java.enable = true;
    seahorse.enable = true;
    thunderbird.enable = true;
    kdeconnect.enable = true;
    obs-studio.enable = true;

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
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = [ "qemu:///system" ];
              uris = [ "qemu:///system" ];
            };
          };
        }
      ];
    };
  };

  environment.systemPackages = [
    ags.package
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
    (pkgs.nautilus.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
      ];
    }))
    pkgs.sushi

    # Desktop environment
    pkgs.xdg-utils
    pkgs.wayfreeze
    pkgs.grim
    pkgs.slurp
    pkgs.tesseract
    #pkgs.kdePackages.xwaylandvideobridge
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
}
