{
  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      connectionConfig."connection.mdns" = 2;
    };

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
      settings.Resolve = {
        DNSSEC = "false";
        DNSOverTLS = "false";
      };
    };
    fail2ban.enable = true;
  };

  systemd = {
    services.NetworkManager-wait-online.enable = false;
    network.wait-online.enable = false;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    wirelessRegulatoryDatabase = true;
  };
}
