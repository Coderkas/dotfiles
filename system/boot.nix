{ pkgs, ... }:
{
  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 3;
        device = "nodev";
        theme = pkgs.catppuccin-grub;
        extraConfig = "set video=DP-2:e";
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
