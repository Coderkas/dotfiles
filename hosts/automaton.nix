{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

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
      cpu = "pi";
      hasDedicatedGpu = false;
    };
    syncthing = {
      enable = true;
      devices = {
        omnissiah.id = "N3QGL6I-Q7SBNDN-TTKTP5L-KDLGFNW-RSVZ263-YQVGUOH-WV5W7GK-CNHIQQI";
        "Pixel 8".id = "YC5A6Q4-MUYTELJ-TKQUECY-X6ORNKC-QQAE2UQ-AHTU5DU-AU7VQ2J-QZEKEQ3";
        servitor.id = "H35QFRA-DRR45Q3-7RCHTAP-AWPZKYT-DI6IJC2-OSNTZVV-PSQEUGM-2YW7NQF";
      };
    };
    interface = "wlan0";
    ipv4 = "192.168.0.101";
  };

  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

  programs.bash.interactiveShellInit = /* sh */ ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking = {
    interfaces.wlan0.ipv4.addresses = [
      {
        address = "192.168.0.4";
        prefixLength = 24;
      }
    ];
    networkmanager.wifi.powersave = lib.mkForce false;
  };

  system.stateVersion = "25.05";
}
