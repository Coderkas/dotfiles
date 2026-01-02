{ config, lib, ... }:
let
  cfg = config.machine;
in
{
  options.machine = {
    interface = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
    ipv4 = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };

  };
  config = lib.mkIf cfg.enableBase {
    networking = {
      hostName = cfg.name; # Define your hostname.
      hosts.${cfg.ipv4} = [ cfg.name ];

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

      interfaces.${cfg.interface}.ipv4.addresses = [
        {
          address = cfg.ipv4;
          prefixLength = 24;
        }
      ];

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

      nftables.enable = true;
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

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.route_localnet" = 1;
    };

    hardware = {
      bluetooth.enable = true;
      wirelessRegulatoryDatabase = true;
    };
  };
}
