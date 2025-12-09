{ lib, ... }:
{
  machine = {
    enableBase = true;
    enableDesktop = false;
    boot.enable = false;
    ssh.enable = true;
    themeName = "Gruvbox";
    owner = "lorkas";
    platform = "aarch64-linux";
    name = "automaton";
    hardware = {
      cpu = "pi 4";
      hasDedicatedGpu = false;
    };
    syncthing = {
      enable = true;
      devices = {
        omnissiah.id = "GUKSJFG-RH6V4HN-SEBLPHJ-NXUENX2-6DZ4ML6-DZ3T3BJ-S7ZS4J7-GCN6FQE";
        "Pixel 8".id = "YC5A6Q4-MUYTELJ-TKQUECY-X6ORNKC-QQAE2UQ-AHTU5DU-AU7VQ2J-QZEKEQ3";
        servitor.id = "H35QFRA-DRR45Q3-7RCHTAP-AWPZKYT-DI6IJC2-OSNTZVV-PSQEUGM-2YW7NQF";
      };
    };
  };

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking.networkmanager.wifi.powersave = lib.mkForce false;
}
