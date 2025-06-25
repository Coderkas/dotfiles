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

    ags.url = "github:Aylur/ags";

    nil.url = "github:oxalica/nil";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        omnissiah = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            host_name = "omnissiah";
            inherit inputs system;
          };
          modules = [
            ./hosts/omnissiah
            ./system
            ./system/desktop
            ./home
            inputs.chaotic.nixosModules.default
            (import ./overlays)
          ];
        };
        servitor = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            host_name = "servitor";
            inherit inputs system;
          };
          modules = [
            ./hosts/servitor
            ./system
            ./system/desktop
            ./home
            (import ./overlays)
          ];
        };
      };
    };
}
