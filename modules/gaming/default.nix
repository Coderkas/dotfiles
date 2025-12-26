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
      base_path,
      exe,
      icon_path,
      menu_name,
      prefix,
      proton_path,
      wayland ? "1",
    }:
    ''
      [Desktop Entry]
      Exec=PROTON_WAYLAND_ENABLE=${wayland} WINEPREFIX="${base_path}/${prefix}" PROTONPATH="${proton_path}" umu-run "${base_path}/${prefix}/drive_c/${exe}"
      Name=${menu_name}
      Path=${base_path}
      Icon=${base_path}/${prefix}/drive_c/${icon_path}
      Terminal=false
      Type=Application
      Version=1.5
    '';
in
{
  options.machine.enableGaming = lib.mkEnableOption "";

  config = lib.mkIf cfg.enableGaming {
    hjem.users.${cfg.owner}.xdg.data = {
      files = {
        "applications/aotr.desktop".text = desktopExec {
          base_path = "/games";
          exe = "AgeoftheRing/AotR_Launcher.exe";
          icon_path = "AgeoftheRing/aotr/aotr.ico";
          menu_name = "Age of the Ring";
          prefix = "aotr-fix";
          proton_path = "${pkgs.proton-ge-bin.steamcompattool}";
        };
        "applications/bfme.desktop".text = desktopExec {
          base_path = "/games";
          exe = "users/steamuser/Desktop/All in One Launcher.lnk";
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

    networking.firewall = {
      allowedUDPPortRanges = [
        {
          from = 8086;
          to = 28088;
        }
      ];
      # interfaces =
      #   let
      #     allowedTCPPortRanges = [
      #       {
      #         from = 8086;
      #         to = 28088;
      #       }
      #     ];
      #     allowedUDPPortRanges = [
      #       {
      #         from = 8086;
      #         to = 28088;
      #       }
      #     ];
      #   in
      #   {
      #     enp6s0 = { inherit allowedTCPPortRanges allowedUDPPortRanges; };
      #     wlo1 = { inherit allowedTCPPortRanges allowedUDPPortRanges; };
      #   };
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
        gamescopeSession.enable = true;
        extest.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
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

      firejail.enable = true;
      wireshark.enable = true;
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
        # PROTON_NO_WM_DECORATION = "1";
        # WINE_NO_WM_DECORATION = "1";
        # WAYLANDDRV_PRIMARY_MONITOR = "DP-2"; # tell at least proton-ge which one is the main monitor on wayland
      };

      # just symlink folder with those into XDG_DATA_HOME
      systemPackages = [
        (pkgs.heroic.override {
          extraPkgs = pkgs: [ pkgs.gamescope ];
        })
        pkgs.wineWowPackages.stagingFull
        pkgs.umu-launcher
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
