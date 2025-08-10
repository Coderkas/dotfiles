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
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 3;
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
