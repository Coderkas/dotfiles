{
  osConfig,
  pkgs,
  inputs,
  system,
  ...
}:
{
  programs.lutris = {
    enable = true;
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
