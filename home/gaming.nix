{
  osConfig,
  pkgs,
  ...
}:
{
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    PROTON_ENABLE_WAYLAND = "1";
    PROTON_NO_WM_DECORATION = "1";
    PROTON_PREFER_SDL_INPUT = "1";
    WINE_NO_WM_DECORATION = "1";
    WINE_PREFER_SDL_INPUT = "1";
  };

  programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      mangohud
      winetricks
      gamescope
      gamemode
      protonup-qt
      proton-ge-custom
      proton-cachyos
    ];
    protonPackages = [
      pkgs.proton-ge-bin
    ];
    steamPackage = osConfig.programs.steam.package;
    winePackages = [ pkgs.wineWowPackages.waylandFull ];
  };
}
