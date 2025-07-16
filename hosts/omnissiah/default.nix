# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  config,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../system/gaming.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages =
      # changing to zen if a kernel version has some sort of regression
      if pkgs.linuxPackages_cachyos.kernel.version == "6.15.4" then
        pkgs.linuxPackages_zen
      else
        pkgs.linuxPackages_cachyos;
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
    kernelParams = [
      # https://gitlab.freedesktop.org/drm/amd/-/issues/2516#note_2119750
      "gpu_sched.sched.policy=0"
    ];

    # Enable LOGITECH_FF option to make controller work if used kernel has it not enabled by default
    #kernelPatches = [
    #  {
    #    name = "logitech-config";
    #    patch = null;
    #    extraConfig = ''
    #      LOGITECH_FF y
    #    '';
    #  }
    #];
  };

  systemd.services = {
    hydrate-reminder = {
      environment = {
        WAYLAND_DISPLAY = "wayland-2";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      path = [
        pkgs.libnotify
        pkgs.mpv
      ];
      serviceConfig.User = config.users.users.lorkas.name;
      script = ''notify-send -i /home/lorkas/dotfiles/assets/chug.png "Reminder" "Stay hydrated!"; mpv /home/lorkas/dotfiles/assets/poi.mp3'';
      startAt = "*-*-* *:30:00";
    };
    rsi-reminder = {
      environment = {
        WAYLAND_DISPLAY = "wayland-2";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      path = [
        pkgs.libnotify
        pkgs.mpv
      ];
      serviceConfig.User = config.users.users.lorkas.name;
      script = ''notify-send -i /home/lorkas/dotfiles/assets/peek.png "Reminder" "Posture check!"; mpv /home/lorkas/dotfiles/assets/poi.mp3'';
      startAt = "hourly";
    };
    shutdown-reminder = {
      environment = {
        WAYLAND_DISPLAY = "wayland-2";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      path = [
        pkgs.libnotify
        pkgs.mpv
      ];
      serviceConfig.User = config.users.users.lorkas.name;
      script = ''notify-send -i /home/lorkas/dotfiles/assets/stare.png -u critical "Attention" "If you dont shutdown now you are gonna regret it in 9 hours!"; mpv /home/lorkas/dotfiles/assets/panic.ogg'';
      startAt = "*-*-* 02:00:00";
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      initrd.enable = true;
      # Ai stuff... i think?
      opencl.enable = true;

      # For running propriatary drivers instead of mesa:
      #amdvlk = {
      #  enable = true;
      #  support32Bit.enable = true;
      #};
    };
    keyboard.qmk.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.lorkas = {
      extraGroups = [
        "adbusers"
        "kvm"
        "libvirtd"
        "gamemode"
      ];
    };
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

  # Virtualisation
  virtualisation = {
    waydroid.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # System specific
    vesktop
    anki
    amdgpu_top
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
