{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  cachyos = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.machine = {
    secureBoot.enable = lib.mkEnableOption "Activate secure boot";
    kernel = lib.mkOption {
      type = lib.types.attrs;
      default = if cachyos.kernel.version != "6.15.4" then cachyos else pkgs.linuxPackages_zen;
    };
  };

  config = lib.mkIf (cfg.cpu != "pi") {
    boot = {
      kernelParams = [
        "acpi_backlight=native"
      ]
      ++ lib.optionals cfg.hasDedicatedGpu [ "gpu_sched.sched.policy=0" ];

      initrd = {
        includeDefaultModules = false;
        kernelModules = [
          "dm_mod"
        ];
        availableKernelModules = [
          "atkbd"
          "ahci"
          "ehci_hcd"
          "ehci_pci"
          "hid_generic"
          "mmc_block"
          "nvme"
          "ohci_hcd"
          "ohci_pci"
          "sd_mod"
          "sr_mod"
          "uas"
          "uhci_hcd"
          "usb_storage"
          "usbhid"
          "xhci_hcd"
          "xhci_pci"
        ];

        systemd.dmVerity.enable = true;
      };

      blacklistedKernelModules = [
        "algif_aead"
      ];

      kernelPackages = cfg.kernel;

      kernel.sysctl = lib.mkIf cfg.desktop.enable {
        "vm.max_map_count" = 2147483642;
        "fs.file-max" = 524288;
        "kernel.split_lock_mitigate" = 0;
      };

      loader = {
        efi.canTouchEfiVariables = true;

        grub = {
          enable = !cfg.secureBoot.enable;
          efiSupport = true;
          useOSProber = true;
          configurationLimit = 3;
          device = "nodev";
          theme = pkgs.catppuccin-grub;
        };

        systemd-boot.enable = lib.mkForce false;
      };
      lanzaboote = {
        enable = cfg.secureBoot.enable;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = 3;
      };

      tmp.cleanOnBoot = true;
    };

    environment.systemPackages = lib.optionals cfg.secureBoot.enable [ pkgs.sbctl ];
  };
}
