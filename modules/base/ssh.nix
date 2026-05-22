{ config, ... }:
{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableBrowserSocket = config.machine.desktop.enable;
  };

  services.openssh.enable = true;
}
