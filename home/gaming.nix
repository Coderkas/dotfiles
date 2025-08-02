{
  osConfig,
  pkgs,
  ...
}:
{
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    PROTON_ENABLE_WAYLAND = "1";
  };

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
