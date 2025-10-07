{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    kernelParams = [ "acpi_backlight=native" ];
    kernelModules = [ "af_packet" ];

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

    tmp.cleanOnBoot = true;

    initrd = {
      kernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "sd_mod"
      ];
      availableKernelModules = [
        "usbhid"
        "sd_mod"
        "uas"
        "usb_storage"
        "ata_piix"
        "virtio_pci"
        "virtio_scsi"
        "ehci_pci"
      ];
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
