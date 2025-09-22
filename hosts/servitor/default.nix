{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Kernel stuff
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "amdgpu.dcdebugmask=0x10" ];
    initrd = {
      availableKernelModules = [
        "usb_storage"
        "sd_mod"
      ];
      luks.devices."luks-e57d3198-6f5b-42d9-a67b-a34a65b71897".device =
        "/dev/disk/by-uuid/e57d3198-6f5b-42d9-a67b-a34a65b71897";
    };

    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="US"
    '';
  };

  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  environment.systemPackages = [
    # Desktop environment
    pkgs.brightnessctl
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
