{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inputs = {
        hyprland-qtutils.inputs = {
          hyprutils.follows = "hyprland/hyprutils";
          hyprland-qt-support.inputs = {
            hyprlang.follows = "hyprland/hyprlang";
            nixpkgs.follows = "hyprland/nixpkgs";
            systems.follows = "hyprland/systems";
          };
        };
        pre-commit-hooks.follows = "";
      };
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

    flint = {
      url = "github:notashelf/flint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      hypr-pkgs = {
        land = inputs.hyprland.packages.${system}.hyprland;
        portal = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
        picker = inputs.hyprpicker.packages.${system}.hyprpicker;
        paper = inputs.hyprpaper.packages.${system}.hyprpaper;
        lock = inputs.hyprlock.packages.${system}.hyprlock;
        idle = inputs.hypridle.packages.${system}.hypridle;
      };

      nvfim = inputs.nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit system;
          myInputs = inputs;
        };
        modules = [ ./nvf ];
      };
    in
    {
      # for testing package without rebuilding system
      packages.${system}.nvfim-test = nvfim.neovim;

      nixosConfigurations = {
        omnissiah = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            host_name = "omnissiah";
            inherit system;
            inherit inputs;
            inherit hypr-pkgs;
            inherit nvfim;
          };
          modules = [
            ./hosts/omnissiah
            ./system
            ./system/desktop
            ./system/gaming.nix
            ./home
            inputs.chaotic.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.nix-gaming.nixosModules.pipewireLowLatency
          ];
        };
        servitor = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            host_name = "servitor";
            inherit system;
            inherit inputs;
            inherit hypr-pkgs;
            inherit nvfim;
          };
          modules = [
            ./hosts/servitor
            ./system
            ./system/desktop
            ./home
            inputs.home-manager.nixosModules.home-manager
            inputs.lanzaboote.nixosModules.lanzaboote
          ];
        };
      };
    };
}
