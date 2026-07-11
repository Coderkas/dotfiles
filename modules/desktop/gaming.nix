{
  config,
  lib,
  npin-src,
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
    hjem.users.${owner}.xdg.data.files = {
      "Steam/compatibilitytools.d/GE-Proton".source = npin-src.proton-ge.outPath;
      "Steam/compatibilitytools.d/proton-cachyos".source = npin-src.proton-cachyos.outPath;
      "Steam/compatibilitytools.d/dwproton".source = npin-src.proton-dw.outPath;
      "Steam/compatibilitytools.d/steamtinkerlaunch".source = pkgs.steamtinkerlaunch.steamcompattool;
    };

    boot.kernelModules = [ "ntsync" ];

    programs = {
      steam = {
        enable = true;
        dedicatedServer.openFirewall = true;
        extraPackages = [ pkgs.pulseaudio ];
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
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = [
          "/home/${owner}/.local/share/Steam/compatibilitytools.d"
        ];
        MESA_SHADER_CACHE_MAX_SIZE = "12G"; # bigger shader cache size so they dont have to be processed every time
        # maybe fix for controller stuff?
        PROTON_PREFER_SDL_INPUT = "1";
        WINE_PREFER_SDL_INPUT = "1";
      };

      systemPackages = [
        pkgs.heroic
        pkgs.wineWow64Packages.stagingFull
        pkgs.umu-launcher
        pkgs.r2modman
        pkgs.prismlauncher
        pkgs.vkbasalt
      ];
    };
  };
}
