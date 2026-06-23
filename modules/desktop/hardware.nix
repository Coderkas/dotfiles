{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
in
{
  config = lib.mkIf cfg.desktop.enable {
    hardware = {
      amdgpu = lib.mkIf cfg.hasDedicatedGpu {
        initrd.enable = true;
      };

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
      udev.packages = [ pkgs.via ]; # Enable udev rules for via compatible devices
      libinput.enable = true;
      upower.enable = true;
      xserver.videoDrivers = lib.optionals cfg.hasDedicatedGpu [ "amdgpu" ];
    };

    environment.systemPackages = [ pkgs.via ] ++ lib.optionals cfg.hasDedicatedGpu [ pkgs.amdgpu_top ];
  };
}
