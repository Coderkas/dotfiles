{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.gaming;
  inherit (config.machine) owner;
in
{
  options.machine.gaming.enable = lib.mkEnableOption "Enable gaming";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "ntsync" ];

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

    users.users.${owner}.extraGroups = [ "gamemode" ];

    services.udev.packages = [ pkgs.game-devices-udev-rules ];

    environment = {
      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = [ "\${HOME}/.steam/root/compatibilitytools.d" ];
        MESA_SHADER_CACHE_MAX_SIZE = "12G"; # bigger shader cache size so they dont have to be processed every time
        # maybe fix for controller stuff?
        PROTON_PREFER_SDL_INPUT = "1";
        WINE_PREFER_SDL_INPUT = "1";
      };

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
