{
  config,
  lib,
  pkgs,
  ...
}:
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
      useDHCP = false;
      useNetworkd = true;

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
      network = {
        wait-online.enable = false;

        networks = {
          "30-default-wired" = {
            matchConfig.Type = "ether";
            networkConfig = {
              DHCP = "yes";
              IPv6AcceptRA = true;
            };
            routes = [
              {
                InitialCongestionWindow = 30;
                InitialAdvertisedReceiveWindow = 30;
              }
            ];
            dhcpV4Config = {
              RouteMetric = 100;
            };
            dhcpV6Config = {
              RouteMetric = 100;
            };
          };
          "30-default-wireless" = {
            matchConfig.Type = "wlan";
            networkConfig = {
              DHCP = "yes";
              IPv6AcceptRA = true;
            };
            routes = [
              {
                InitialCongestionWindow = 30;
                InitialAdvertisedReceiveWindow = 30;
              }
            ];
            dhcpV4Config = {
              RouteMetric = 200;
            };
            dhcpV6Config = {
              RouteMetric = 200;
            };
          };
        };
      };
    };

    hardware = {
      bluetooth.enable = true;
      wirelessRegulatoryDatabase = true;
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
    };

    environment.systemPackages = [
      pkgs.mtr
      pkgs.traceroute
      pkgs.bandwhich
    ];
  };
}
