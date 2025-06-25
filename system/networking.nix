{ host_name, ... }:
{
  networking = {
    hostName = host_name; # Define your hostname.
    networkmanager.enable = true;
    # wireless.enable = true; # Enables wireless support via wpa_supplicant.
  };
}
