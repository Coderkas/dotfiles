{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true; # Allow unfree packages
    hostPlatform = lib.mkDefault system;
  };

  # Just in case
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  nix = {
    package = pkgs.nixVersions.nix_2_30;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
      builders-use-substitutes = true;

      trusted-users = [ "lorkas" ];
      download-buffer-size = 500000000;
      keep-going = true;
      warn-dirty = false;
      accept-flake-config = false;
    };

    optimise = {
      automatic = true;
      dates = [ "11:00" ];
    };

    channel.enable = false;
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
