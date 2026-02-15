{
  machine = {
    enableBase = true;
    enableDesktop = true;
    ssh.enable = true;
    themeName = "Gruvbox";
    terminals = {
      primary = "ghostty";
      enableGhostty = true;
    };
    owner = "lorkas";
    platform = "x86_64-linux";
    name = "medusa";
    hardware = {
      cpu = "intel";
      hasDedicatedGpu = false;
    };
    runner.name = "anyrun";
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

  swapDevices = [
    { device = "/dev/disk/by-uuid/18e0c142-b5c5-4657-ae3b-314b3db3109c"; }
  ];

  system.stateVersion = "25.11";
}
