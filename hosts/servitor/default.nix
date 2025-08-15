# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
