{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
in
{
  options.machine.enableVirtualisation = lib.mkEnableOption "";

  config = lib.mkIf cfg.enableVirtualisation {
    networking.firewall.trustedInterfaces = [
      "br0"
      "virbr0"
    ];

    programs.virt-manager.enable = true;

    users.users.${cfg.owner}.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options ignore_msrs=1 report_ignored_msrs=0
    '';

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
  };
}
