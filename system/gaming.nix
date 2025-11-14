{
  pkgs,
  inputs,
  system,
  ...
}:
{
  programs = {
    gamescope = {
      enable = true;
      capSysNice = false;
      args = [
        "-W 2560"
        "-H 1440"
        "-f"
        "--rt"
        "--force-grab-cursor"
      ];
    };

    # Steam
    steam = {
      enable = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      extest.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [
        pkgs.proton-ge-custom
        pkgs.proton-cachyos
        pkgs.steamtinkerlaunch
      ];
    };

    gamemode = {
      enable = true;
      settings.general = {
        softrealtime = "auto";
        renice = 15;
      };
    };
  };

  services = {
    # Pipewire goes brr thanks to nix-gaming by fufexan
    pipewire.lowLatency.enable = true;
    # Enable udev rules for various devices collected in this repo: https://codeberg.org/fabiscafe/game-devices-udev
    udev.packages = [ pkgs.game-devices-udev-rules ];
  };

  hardware = {
    steam-hardware.enable = true;
    uinput.enable = true;
  };

  environment = {
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      # bigger shader cache size so they dont have to be processed every time
      MESA_SHADER_CACHE_MAX_SIZE = "12G";
      # maybe fix for controller stuff?
      PROTON_PREFER_SDL_INPUT = "1";
      WINE_PREFER_SDL_INPUT = "1";

      # Experimental wayland stuff
      /*
        PROTON_ENABLE_WAYLAND = "1";
        PROTON_NO_WM_DECORATION = "1";
        WINE_NO_WM_DECORATION = "1";
      */
      # tell at least proton-ge which one is the main monitor on wayland
      # WAYLANDDRV_PRIMARY_MONITOR = "DP-2";
    };

    systemPackages = [
      (pkgs.heroic.override {
        extraPkgs = pkgs: [ pkgs.gamescope ];
      })
      #inputs.nix-gaming.packages.${system}.wine-tkg
      #inputs.nix-gaming.packages.${system}.wine-cachyos
      inputs.umu.packages.${system}.default
      pkgs.wineWowPackages.waylandFull
      pkgs.winetricks
      pkgs.r2modman
      pkgs.prismlauncher
      pkgs.linuxConsoleTools
      pkgs.vkbasalt
      pkgs.steamtinkerlaunch
    ];
  };
}
