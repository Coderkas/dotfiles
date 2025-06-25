{
  osConfig,
  pkgs,
  ...
}:
{
  programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      mangohud
      winetricks
      gamescope
      gamemode
      protonup-qt
    ];
    protonPackages = [ pkgs.proton-ge-bin ];
    steamPackage = osConfig.programs.steam.package;
    winePackages = [ pkgs.wineWowPackages.waylandFull ];
  };
}
