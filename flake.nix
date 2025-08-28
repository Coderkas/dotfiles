{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };
    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs = {
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
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

    nil.url = "github:oxalica/nil";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";

    umu = {
      url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      # quickly switch between stable and unstable hyprland packages
      hypr-pkgs =
        if true then
          {
            land = inputs.hyprland.packages.${system}.hyprland;
            portal = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
            picker = inputs.hyprpicker.packages.${system}.hyprpicker;
            paper = inputs.hyprpaper.packages.${system}.hyprpaper;
            lock = inputs.hyprlock.packages.${system}.hyprlock;
            idle = inputs.hypridle.packages.${system}.hypridle;
          }
        else
          {
            land = inputs.nixpkgs.legacyPackages.${system}.hyprland;
            portal = inputs.nixpkgs.legacyPackages.${system}.xdg-desktop-portal-hyprland;
            picker = inputs.nixpkgs.legacyPackages.${system}.hyprpicker;
            paper = inputs.nixpkgs.legacyPackages.${system}.hyprpaper;
            lock = inputs.nixpkgs.legacyPackages.${system}.hyprlock;
            idle = inputs.nixpkgs.legacyPackages.${system}.hypridle;
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
      # for resting package without rebuilding system
      nvfim-test = nvfim.neovim;

      nixosConfigurations = {
        omnissiah = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            host_name = "omnissiah";
            inherit
              system
              inputs
              hypr-pkgs
              nvfim
              ;
          };
          modules = [
            ./hosts/omnissiah
            ./system
            ./system/desktop
            ./home
            ./overlays
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
            inherit
              system
              inputs
              hypr-pkgs
              nvfim
              ;
          };
          modules = [
            ./hosts/servitor
            ./system
            ./system/desktop
            ./home
            ./overlays
            inputs.home-manager.nixosModules.home-manager
            inputs.lanzaboote.nixosModules.lanzaboote
          ];
        };
      };
    };
}
