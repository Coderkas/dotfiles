{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hjem.url = "github:feel-co/hjem";

    systems.url = "github:nix-systems/default-linux";

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs = {
        jovian.follows = "";
        home-manager.follows = "";
      };
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.pre-commit-hooks.follows = "";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        hyprwayland-scanner.follows = "hyprland/hyprwayland-scanner";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };
    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs = {
        hyprutils.follows = "hyprland/hyprutils";
        hyprwayland-scanner.follows = "hyprland/hyprwayland-scanner";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        hyprwayland-scanner.follows = "hyprland/hyprwayland-scanner";
        hyprland-protocols.follows = "hyprland/hyprland-protocols";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        hyprwayland-scanner.follows = "hyprland/hyprwayland-scanner";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    umu = {
      url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
        rust-overlay.follows = "chaotic/rust-overlay";
        pre-commit-hooks-nix.follows = "";
      };
    };

    nvf = {
      url = "github:notashelf/nvf/v0.8";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
      };
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun.url = "github:anyrun-org/anyrun";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      customPkgs = import ./pkgs { inherit inputs; };
    in
    {
      inherit (customPkgs) packages;
      inherit (customPkgs) devShells;

      nixosConfigurations = {
        omnissiah = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs customPkgs; };
          modules = [
            ./modules
            ./hosts/omnissiah.nix
          ];
        };
        servitor = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs customPkgs; };
          modules = [
            ./hosts/servitor
            ./system
            ./system/desktop
            ./home
          ];
        };
      };
    };
}
