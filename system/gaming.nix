{ pkgs, ... }:
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
      protontricks = {
        enable = true;
      };
      gamescopeSession.enable = true;
      extest.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [
        pkgs.proton-ge-custom
        pkgs.proton-cachyos
      ];
    };

    gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 15;
        };
      };
    };
  };

  # Enable udev rules for various devices collected in this repo: https://codeberg.org/fabiscafe/game-devices-udev
  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  hardware = {
    steam-hardware.enable = true;
    uinput.enable = true;
  };

  environment.systemPackages = with pkgs; [
    (heroic.override {
      extraPkgs = pkgs: [ pkgs.gamescope ];
    })
    wineWowPackages.waylandFull
    mangohud
    steamtinkerlaunch
    protonup-qt
    winetricks
    r2modman
    prismlauncher
    linuxConsoleTools
    jstest-gtk
    vkbasalt
  ];
}
