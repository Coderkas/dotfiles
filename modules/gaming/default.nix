{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;

  desktopExec =
    {
      exe,
      icon_path,
      menu_name,
      prefix,
      proton_path,
      wayland ? "1",
    }:
    ''
      [Desktop Entry]
      Exec=DISPLAY=: PROTON_WAYLAND_ENABLE=${wayland} WINEPREFIX="${cfg.extraGamesPath}/${prefix}" PROTONPATH="${proton_path}" umu-run "${cfg.extraGamesPath}/${prefix}/drive_c/${exe}"
      Name=${menu_name}
      Path=${cfg.extraGamesPath}
      Icon=${cfg.extraGamesPath}/${prefix}/drive_c/${icon_path}
      Terminal=false
      Type=Application
      Version=1.5
    '';
in
{
  options.machine = {
    enableGaming = lib.mkEnableOption "";
    extraGamesPath = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "/home/${cfg.owner}/Games";
    };
  };

  config = lib.mkIf cfg.enableGaming {
    hjem.users.${cfg.owner}.xdg.data = {
      files = {
        "applications/aotr.desktop".text = desktopExec {
          exe = "AgeoftheRing/AotR_Launcher.exe";
          icon_path = "AgeoftheRing/aotr/aotr.ico";
          menu_name = "Age of the Ring";
          prefix = "aotr-fix";
          proton_path = "${pkgs.proton-ge-bin.steamcompattool}";
        };
        "applications/bfme.desktop".text = desktopExec {
          exe = "users/${cfg.owner}/AppData/Roaming/BFME\ All\ In\ One\ Launcher/AllInOneLauncher.exe";
          icon_path = "proton_shortcuts/icons/128x128/apps/B76C_AllInOneLauncher.0.png";
          menu_name = "Battle for Middle-earth";
          proton_path = "${pkgs.proton-ge-bin.steamcompattool}";
          prefix = "bfme";
        };
      };
    };

    systemd.user.tmpfiles.users.${cfg.owner}.rules = [
      "L+ /home/${cfg.owner}/.local/share/applications/games-impure - - - - /home/${cfg.owner}/dotfiles/modules/gaming/games-impure"
    ];

    networking.nftables.tables.bfme = {
      family = "ip";
      content = ''
        chain bfme-in {
          type filter hook input priority filter;
          ip saddr ${cfg.ipv4} udp sport 8086 drop
          udp sport 8086 accept
        }
      '';
    };

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

        # Experimental wayland stuff
        # PROTON_ENABLE_WAYLAND = "1";
        PROTON_NO_WM_DECORATION = "1";
        WINE_NO_WM_DECORATION = "1";
        # WAYLANDDRV_PRIMARY_MONITOR = "DP-2"; # tell at least proton-ge which one is the main monitor on wayland
      };

      # just symlink folder with those into XDG_DATA_HOME
      systemPackages = [
        pkgs.heroic
        pkgs.wineWowPackages.stagingFull
        pkgs.umu-launcher
        pkgs.winetricks
        pkgs.r2modman
        pkgs.prismlauncher
        pkgs.vkbasalt
      ];
    };
  };
}
