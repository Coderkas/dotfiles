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
    boot.kernelModules = [ "ntsync" ];

    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraEnv.LD_PRELOAD = "libextest.so";
          extraLibraries = _p: with _p; [ extest ];
          extraPkgs = _p: [ _p.pulseaudio ];
        };
        dedicatedServer.openFirewall = true;
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
          npin-src.proton-ge.outPath
          npin-src.proton-cachyos.outPath
          npin-src.proton-dw.outPath
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
