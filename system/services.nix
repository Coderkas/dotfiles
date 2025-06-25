{ pkgs, ... }:
{
  # Something about cpu scheduling and pipewire
  security.rtkit.enable = true;

  services = {
    # More scheduling stuff
    scx.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      group = "users";
      user = "lorkas";
      dataDir = "/home/lorkas/Syncthing";
      configDir = "/home/lorkas/Syncthing/.config/syncthing";
    };

    printing = {
      enable = true;
      drivers = [
        # Covers most printers to fix errors
        pkgs.splix
        pkgs.gutenprint
        pkgs.hplip
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable the OpenSSH daemon.
    openssh.enable = true;
    fail2ban.enable = true;

    devmon.enable = true;
    udisks2.enable = true;
    # Enable udev rules for via compatible devices
    udev.packages = [ pkgs.via ];
    gvfs.enable = true;
    fwupd.enable = true;
  };
}
