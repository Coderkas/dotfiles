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
      device = "/dev/disk/by-uuid/f846f738-5fb2-44e8-88b5-a877149d2e2c";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/A6DD-C55D";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6c9b92a7-0a6a-492b-a728-f0507ab9a2ad"; }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
