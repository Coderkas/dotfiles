{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.framework-16-7040-amd ];

  machine = {
    desktop = {
      enable = true;
      bar = "ironbar";
      browser.name = "zen-browser";
      runner.name = "anyrun";
      terminal.name = "ghostty";

      primaryMonitor = "eDP-1";
    };
    gaming.enable = true;
    themeName = "Gruvbox";
    owner = "lorkas";
    platform = "x86_64-linux";
    cpu = "amd";
    syncthing = {
      enable = true;
      devices."automaton".id = "RS6ZTBC-XHEWDBH-4EU6JUV-4NPHL3I-D66CZDO-JNEMRQL-OSVMTH5-Q5RZUQP";
    };
  };
  # Kernel stuff
  boot = {
    kernelParams = [ "amdgpu.dcdebugmask=0x10" ];
    initrd = {
      availableKernelModules = [ "thunderbolt" ];
      luks.devices."luks-7a488d44-e655-44ba-8871-241df2728fe1".device =
        "/dev/disk/by-uuid/7a488d44-e655-44ba-8871-241df2728fe1";
      luks.devices."luks-e57d3198-6f5b-42d9-a67b-a34a65b71897".device =
        "/dev/disk/by-uuid/e57d3198-6f5b-42d9-a67b-a34a65b71897";
    };
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="US"
    '';
  };

  services = {
    power-profiles-daemon.enable = true;
    fprintd.enable = true;
  };

  networking = {
    hostName = "servitor";
    firewall.checkReversePath = false;
  };

  environment.systemPackages = [
    pkgs.brightnessctl
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/8bb605f3-824a-40d8-a22c-4dc3d660a7af";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6369-1E47";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/adcbb887-8ee3-4b4c-a1d7-da7de86a1ebd"; }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
