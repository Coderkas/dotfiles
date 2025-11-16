{ config, lib, ... }:
{
  config = lib.mkIf config.machine.enableBase {
    networking = {
      hostName = config.machine.name; # Define your hostname.
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";

        wifi = {
          macAddress = "random";
          powersave = true;
          scanRandMacAddress = true;
        };

        connectionConfig."connection.mdns" = 2;
      };
      # wireless.enable = true; # Enables wireless support via wpa_supplicant.
      useDHCP = lib.mkForce false;
      useNetworkd = lib.mkForce true;

      nameservers = [
        # Cloudflare
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"

        # Quad9
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];

      firewall.allowPing = false;
    };

    services = {
      resolved = {
        enable = true;
        dnssec = "false";
        dnsovertls = "true";
      };
      fail2ban.enable = true;
    };

    systemd = {
      services.NetworkManager-wait-online.enable = false;
      network.wait-online.enable = false;
    };

    hardware = {
      bluetooth.enable = true;
      wirelessRegulatoryDatabase = true;
    };
  };
}
