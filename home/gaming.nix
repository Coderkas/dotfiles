{
  osConfig,
  pkgs,
  inputs,
  system,
  ...
}:
let
  lutris-unwrapped-git = pkgs.lutris-unwrapped.overrideAttrs (_: {
    # Bleeding edge lutris 06.10.2025
    src = pkgs.fetchFromGitHub {
      owner = "lutris";
      repo = "lutris";
      rev = "0c93c2fad546e684346c8fe3179ab797d5e033f3";
      hash = "sha256-mgFe2Zbb1IjJ5V390xdVqkaEeP4tvae5dcxZPXZI1wU=";
    };
  });
in
{
  programs.lutris = {
    enable = true;
    package = pkgs.lutris.override { lutris-unwrapped = lutris-unwrapped-git; };
    extraPackages = [
      pkgs.winetricks
      pkgs.gamescope
      pkgs.gamemode
    ];
    protonPackages = [
      pkgs.proton-ge-bin
    ];
    steamPackage = osConfig.programs.steam.package;
    winePackages = [
      pkgs.wineWowPackages.waylandFull
      inputs.nix-gaming.packages.${system}.wine-tkg
      inputs.nix-gaming.packages.${system}.wine-cachyos
    ];
  };
}
