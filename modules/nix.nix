{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.nix;
  inherit (config.machine) owner;
in
{
  options = {
    machine.nix.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.machine.enableBase;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      config.allowUnfree = true; # Allow unfree packages
      hostPlatform = lib.mkDefault config.machine.platform;
      overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    };

    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1"; # Just in case

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 2";
      };
      flake = "/home/${owner}/dotfiles";
    };

    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
          "cgroups"
        ];

        substituters = [
          "https://cache.nixos.org?priority=0"
          "https://nix-community.cachix.org?priority=80"
          "https://hyprland.cachix.org?priority=60"
          "https://nix-gaming.cachix.org?priority=70"
          "https://attic.xuyh0120.win/lantian?priority=50"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
        builders-use-substitutes = true;

        trusted-users = [ owner ];
        download-buffer-size = 500000000;
        keep-going = true;
        warn-dirty = false;
        accept-flake-config = false;
        use-cgroups = true;
      };

      optimise = {
        automatic = true;
        dates = [ "11:00" ];
      };

      channel.enable = false;
      registry = builtins.mapAttrs (name: _: { flake = inputs.${name}; }) inputs;
    };
  };
}
