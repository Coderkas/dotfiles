{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  hostName = "automaton";
  address = "192.168.0.11";
in
{
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  machine = {
    themeName = "Gruvbox";
    owner = "lorkas";
    platform = "aarch64-linux";
    cpu = "pi";
    syncthing = {
      enable = true;
      devices = {
        omnissiah.id = "N3QGL6I-Q7SBNDN-TTKTP5L-KDLGFNW-RSVZ263-YQVGUOH-WV5W7GK-CNHIQQI";
        "Pixel 8".id = "YC5A6Q4-MUYTELJ-TKQUECY-X6ORNKC-QQAE2UQ-AHTU5DU-AU7VQ2J-QZEKEQ3";
        servitor.id = "H35QFRA-DRR45Q3-7RCHTAP-AWPZKYT-DI6IJC2-OSNTZVV-PSQEUGM-2YW7NQF";
      };
    };
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
    inherit hostName; # Define your hostname.
    interfaces.wlan0.ipv4.addresses = [
      {
        inherit address;
        prefixLength = 24;
      }
    ];

    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp6s0";
    };

    networkmanager.wifi.powersave = lib.mkForce false;
  };

  environment.etc.hosts.source = lib.mkForce (
    pkgs.writeText "hosts" ''
      127.0.0.1 localhost
      ${address} ${hostName}
    ''
  );

  system.stateVersion = "25.05";
}
