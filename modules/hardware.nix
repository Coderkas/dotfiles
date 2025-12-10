{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.hardware;
  inherit (config.machine) owner;
in
{
  options.machine.hardware = {
    cpu = lib.mkOption {
      type = lib.types.enum [
        "intel"
        "amd"
        "pi"
      ];
    };
    hasDedicatedGpu = lib.mkEnableOption "";
  };

  config = lib.mkMerge [
    (lib.mkIf config.machine.enableBase {
      hardware.enableAllFirmware = lib.mkDefault true;
      services.fwupd.enable = true;
    })
    (lib.mkIf (cfg.cpu == "pi") {
      hardware.deviceTree = {
        enable = true;
        filter = "*rpi-4-*.dtb";
      };

      environment.systemPackages = [
        pkgs.libraspberrypi
        pkgs.raspberrypi-eeprom
      ];
    })
    (lib.mkIf (cfg.cpu == "intel") {
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
      boot.kernelModules = [ "kvm-intel" ];
    })
    (lib.mkIf (cfg.cpu == "amd") {
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
      boot.kernelModules = [ "kvm-amd" ];
    })
    (lib.mkIf config.machine.enableDesktop {
      hjem.users.${owner}.xdg.config.files."udiskie/config.yml".text = ''
        program_options:
          automount: true
          notify: true
          tray: auto
      '';

      systemd.user.services.udiskie = {
        description = "udiskie mount daemon";
        after = [
          "graphical-session.target"
          "tray.target"
        ];
        requires = [ "tray.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie --appindicator";
        wantedBy = [ "graphical-session.target" ];
      };

      hardware = {
        keyboard.qmk.enable = true;
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        opentabletdriver = {
          enable = true;
          daemon.enable = true;
        };
        uinput.enable = true;
      };

      services = {
        fstrim = {
          enable = true;
          interval = "weekly";
        };
        udisks2.enable = true;
        udev.packages = [ pkgs.via ]; # Enable udev rules for via compatible devices
        libinput.enable = true;
        upower.enable = true;
      };

      environment.systemPackages = [
        pkgs.via
        pkgs.udiskie
      ];
    })
    (lib.mkIf cfg.hasDedicatedGpu {
      hardware.amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };

      boot = {
        kernelParams = [ "gpu_sched.sched.policy=0" ];
        kernelModules = [ "amdgpu" ];
      };

      services.xserver.videoDrivers = [ "amdgpu" ];
      environment.systemPackages = [ pkgs.amdgpu_top ];
    })
  ];
}
