{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Kernel stuff
  boot = {
    kernelPackages =
      # changing to zen if a kernel version has some sort of regression
      if pkgs.linuxPackages_cachyos.kernel.version == "6.15.4" then
        pkgs.linuxPackages_zen
      else
        pkgs.linuxPackages_cachyos;
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "fs.file-max" = 524288;
      "kernel.split_lock_mitigate" = 0;
    };
    # https://gitlab.freedesktop.org/drm/amd/-/issues/2516#note_2119750
    kernelParams = [ "gpu_sched.sched.policy=0" ];
    kernelModules = [
      "kvm-intel"
      "amdgpu"
    ];
  };

  systemd.services = {
    hydrate-reminder = {
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      path = [
        pkgs.libnotify
        pkgs.mpv
      ];
      serviceConfig.User = config.users.users.lorkas.name;
      script = ''notify-send -i /home/lorkas/dotfiles/assets/chug.png "Reminder" "Stay hydrated!"; mpv /home/lorkas/dotfiles/assets/poi.mp3 --volume=100'';
      startAt = "*-*-* *:30:00";
    };
    rsi-reminder = {
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      path = [
        pkgs.libnotify
        pkgs.mpv
      ];
      serviceConfig.User = config.users.users.lorkas.name;
      script = ''notify-send -i /home/lorkas/dotfiles/assets/peek.png "Reminder" "Posture check!"; mpv /home/lorkas/dotfiles/assets/poi.mp3 --volume=100'';
      startAt = "hourly";
    };
    shutdown-reminder = {
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      path = [
        pkgs.libnotify
        pkgs.mpv
      ];
      serviceConfig.User = config.users.users.lorkas.name;
      script = ''notify-send -i /home/lorkas/dotfiles/assets/stare.png -u critical "Attention" "If you dont shutdown now you are gonna regret it in 9 hours!"; mpv /home/lorkas/dotfiles/assets/panic.ogg --volume=100'';
      startAt = "*-*-* 02:00:00";
    };
  };

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true; # Ai stuff... i think?
    };
    keyboard.qmk.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault true;
  };

  users = {
    users.lorkas.extraGroups = [
      "adbusers"
      "kvm"
      "libvirtd"
      "gamemode"
    ];
    groups.libvirtd.members = [ "lorkas" ];
  };

  programs = {
    adb.enable = true;
    virt-manager.enable = true;
    ausweisapp = {
      enable = true;
      openFirewall = true;
    };
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };
    atd.enable = true;
  };

  virtualisation = {
    waydroid.enable = false;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  environment.systemPackages = [
    pkgs.anki
    pkgs.amdgpu_top
  ];

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
