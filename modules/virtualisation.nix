{
  config,
  customPkgs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.virtualisation;
  inherit (config.machine) owner platform;
in
{
  options.machine.virtualisation = {
    enableVMs = lib.mkEnableOption "";
    enableWaydroid = lib.mkEnableOption "";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enableVMs || cfg.enableWaydroid) {
      users.users.${owner}.extraGroups = [ "kvm" ];
      networking.firewall.trustedInterfaces = [ "br0" ];
    })
    (lib.mkIf cfg.enableVMs {
      networking.firewall.trustedInterfaces = [ "virbr0" ];
      programs = {
        virt-manager.enable = true;
        dconf.profiles.user.databases = [
          {
            settings."org/virt-manager/virt-manager/connections" = {
              autoconnect = [ "qemu:///system" ];
              uris = [ "qemu:///system" ];
            };
          }
        ];
      };

      users = {
        users.${owner}.extraGroups = [ "libvirtd" ];
        groups.libvirtd.members = [ owner ];
      };

      virtualisation = {
        libvirtd = {
          enable = true;
          onBoot = "ignore";
          onShutdown = "shutdown";
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = false;
          };
        };
        spiceUSBRedirection.enable = true;
      };
    })
    (lib.mkIf cfg.enableWaydroid {
      virtualisation.waydroid.enable = true;
      environment.systemPackages = [
        customPkgs.packages.${platform}.waydroid_script
      ];
    })
  ];
}
