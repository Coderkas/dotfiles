{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
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
      timeout = 0;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "var/lib/sbctl";
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
