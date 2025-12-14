{ pkgs, ... }:
{
  machine = {
    enableBase = true;
    enableDesktop = true;
    boot.enableSecure = true;
    enableGaming = true;
    ssh.enable = true;
    themeName = "Gruvbox";
    terminals = {
      primary = "ghostty";
      enableGhostty = true;
      enableKitty = true;
    };
    owner = "lorkas";
    platform = "x86_64-linux";
    name = "omnissiah";
    hardware = {
      cpu = "intel";
      hasDedicatedGpu = true;
    };
    hyprland.mainMonitor = "DP-2";
    dunst.monitor = "DP-3";
    virtualisation = {
      enableVMs = true;
      enableWaydroid = true;
    };
    syncthing.devices."automaton".id =
      "RS6ZTBC-XHEWDBH-4EU6JUV-4NPHL3I-D66CZDO-JNEMRQL-OSVMTH5-Q5RZUQP";
    runner.name = "anyrun";
  };

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e964b89f-c596-43a8-bea1-aaa7ffc8af4b";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/4A86-71C7";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/games" = {
      device = "/dev/disk/by-uuid/87ed6a83-833e-40d9-a11e-5e7fe8f48aae";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/42a04859-f898-4131-836d-985dee4e7a3c"; }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
