{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    loader = {
      #grub = {
      #  enable = true;
      #  efiSupport = true;
      #  useOSProber = true;
      #  configurationLimit = 3;
      #  device = "nodev";
      #  theme = pkgs.catppuccin-grub;
      #};

      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    # Secure boot
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 3;
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
