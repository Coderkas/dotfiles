{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  ng = inputs.nix-gaming.packages.${cfg.platform};
  umu-launcher = inputs.umu.packages.${cfg.platform}.default;
in
{
  options.machine.enableGaming = lib.mkEnableOption "";

  config = lib.mkIf cfg.enableGaming {
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

    users.users.${cfg.owner}.extraGroups = [ "gamemode" ];

    services.udev.packages = [ pkgs.game-devices-udev-rules ];
    hardware.steam-hardware.enable = true;

    environment = {
      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        MESA_SHADER_CACHE_MAX_SIZE = "12G"; # bigger shader cache size so they dont have to be processed every time
        # maybe fix for controller stuff?
        PROTON_PREFER_SDL_INPUT = "1";
        WINE_PREFER_SDL_INPUT = "1";

        # Experimental wayland stuff
        # PROTON_ENABLE_WAYLAND = "1";
        # PROTON_NO_WM_DECORATION = "1";
        # WINE_NO_WM_DECORATION = "1";
        # WAYLANDDRV_PRIMARY_MONITOR = "DP-2"; # tell at least proton-ge which one is the main monitor on wayland
      };

      systemPackages = [
        (pkgs.heroic.override {
          extraPkgs = pkgs: [ pkgs.gamescope ];
        })
        ng.wine-tkg
        ng.wine-cachyos
        umu-launcher
        pkgs.wineWowPackages.waylandFull
        pkgs.winetricks
        pkgs.r2modman
        pkgs.prismlauncher
        pkgs.linuxConsoleTools
        pkgs.vkbasalt
        pkgs.steamtinkerlaunch
      ];
    };
  };
}
