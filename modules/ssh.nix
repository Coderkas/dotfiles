{ config, lib, ... }:
let
  cfg = config.machine.ssh;
in
{
  options.machine.ssh.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = config.machine.enableDesktop;
    };

    services.openssh.enable = true;
  };
}
