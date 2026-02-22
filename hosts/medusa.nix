{ lib, pkgs, ... }:
{
  machine = {
    enableBase = true;
    enableDesktop = true;
    ssh.enable = true;
    themeName = "Gruvbox";
    terminals = {
      primary = "kitty";
      enableKitty = true;
    };
    owner = "lorkas";
    platform = "x86_64-linux";
    name = "medusa";
    hardware = {
      cpu = "intel";
      hasDedicatedGpu = false;
    };
    hyprland.mainMonitor = "eDP-1";
    dunst.monitor = "eDP-1";
    runner.name = "anyrun";
    interface = "wlp3s0";
    ipv4 = "192.168.0.14";
    syncthing.enable = false;
  };

  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };
    thermald.enable = true;
    thinkfan.enable = true;
  };

  hardware.graphics = {
    extraPackages = [ pkgs.intel-vaapi-driver ];
    extraPackages32 = [ pkgs.intel-vaapi-driver ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d7ea3691-d383-48ae-ad81-2a038ce536bd";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/0250-026C";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  systemd.user.services.wvkbd-daemon = {
    after = [ "graphical-session.target" ];
    description = "wvkbd auto-start";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = ''${lib.getExe pkgs.wvkbd} --hidden --alpha 200 -L 280 --fn "JetBrainsMono Nerd Font"'';
    };
  };

  environment.systemPackages = [
    pkgs.wvkbd
  ];

  swapDevices = [
    { device = "/dev/disk/by-uuid/18e0c142-b5c5-4657-ae3b-314b3db3109c"; }
  ];

  system.stateVersion = "25.11";
}
