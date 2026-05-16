{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
in
{
  options.machine = {
    enableGaming = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enableGaming {
    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
        extest.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = [
          pkgs.steamtinkerlaunch.steamcompattool
          pkgs.proton-ge-bin.steamcompattool
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

    environment = {
      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = [ "\${HOME}/.steam/root/compatibilitytools.d" ];
        MESA_SHADER_CACHE_MAX_SIZE = "12G"; # bigger shader cache size so they dont have to be processed every time
        # maybe fix for controller stuff?
        PROTON_PREFER_SDL_INPUT = "1";
        WINE_PREFER_SDL_INPUT = "1";
      };

      # just symlink folder with those into XDG_DATA_HOME
      systemPackages = [
        pkgs.heroic
        pkgs.wineWow64Packages.stagingFull
        pkgs.umu-launcher
        pkgs.winetricks
        pkgs.r2modman
        pkgs.prismlauncher
        pkgs.vkbasalt
      ];
    };
  };
}
