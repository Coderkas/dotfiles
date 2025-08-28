{
  osConfig,
  pkgs,
  inputs,
  system,
  ...
}:
{
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    PROTON_ENABLE_WAYLAND = "1";
    PROTON_NO_WM_DECORATION = "1";
    # tell at least proton-ge which one is the main monitor on wayland
    WAYLANDDRV_PRIMARY_MONITOR = "DP-2";
    WINE_NO_WM_DECORATION = "1";
    # maybe fix for controller stuff?
    PROTON_PREFER_SDL_INPUT = "1";
    WINE_PREFER_SDL_INPUT = "1";
    # bigger shader cache size so they dont have to be processed every time
    MESA_SHADER_CACHE_MAX_SIZE = "12G";
  };

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
      inputs.nix-gaming.packages.${system}.wine-ge
      inputs.nix-gaming.packages.${system}.wine-tkg
      inputs.nix-gaming.packages.${system}.wine-cachyos
    ];
  };
}
