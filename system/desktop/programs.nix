{ hypr-pkgs, ... }:
{
  programs = {
    java.enable = true;
    seahorse.enable = true;
    thunderbird.enable = true;
    kdeconnect.enable = true;

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
}
