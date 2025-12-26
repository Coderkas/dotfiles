{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.boot;
  cachyos = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
in
{
  options.machine.boot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.machine.enableBase;
    };
    enableSecure = lib.mkEnableOption "Activate Secure boot";
    kernel = lib.mkOption {
      type = lib.types.attrs;
      default = if cachyos.kernel.version != "6.15.4" then cachyos else pkgs.linuxPackages_zen;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot = {
          kernelParams = [ "acpi_backlight=native" ];
          kernelModules = [ "af_packet" ];
          kernelPackages = cfg.kernel;

          loader.efi.canTouchEfiVariables = true;
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
      }
      (lib.mkIf (!cfg.enableSecure) {
        boot.loader.grub = {
          enable = true;
          efiSupport = true;
          useOSProber = true;
          configurationLimit = 3;
          device = "nodev";
          theme = pkgs.catppuccin-grub;
        };
      })
      (lib.mkIf cfg.enableSecure {
        boot = {
          loader.systemd-boot.enable = lib.mkForce false;
          lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
            configurationLimit = 3;
          };
        };

        environment.systemPackages = [ pkgs.sbctl ];
      })
      (lib.mkIf config.machine.enableDesktop {
        boot.kernel.sysctl = {
          "vm.max_map_count" = 2147483642;
          "fs.file-max" = 524288;
          "kernel.split_lock_mitigate" = 0;
        };
      })
    ]
  );
}
