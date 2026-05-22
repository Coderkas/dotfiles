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
  options.machine.vms.enable = lib.mkEnableOption "Enable vm stuff";

  config = lib.mkIf cfg.vms.enable {
    assertions = [
      {
        assertion = cfg.cpu == "intel" || cfg.cpu == "amd";
        message = "Either my virtualisation module needs to be patched for ${cfg.cpu} or I fucked up.";
      }
    ];

    networking.firewall.trustedInterfaces = [
      "br0"
      "virbr0"
    ];

    programs.virt-manager.enable = true;

    users.users.${cfg.owner}.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    boot = {
      kernelModules = [ "kvm-${cfg.cpu}" ];
      extraModprobeConfig = ''
        options kvm_${cfg.cpu} nested=1
        options kvm_${cfg.cpu} emulate_invalid_guest_state=0
        options ignore_msrs=1 report_ignored_msrs=0
      '';
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
  };
}
