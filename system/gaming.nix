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

  environment.systemPackages = [
    (pkgs.heroic.override {
      extraPkgs = pkgs: [ pkgs.gamescope ];
    })
    inputs.nix-gaming.packages.${system}.wine-ge
    inputs.nix-gaming.packages.${system}.wine-tkg
    #inputs.nix-gaming.packages.${system}.wine-cachyos
    inputs.umu.packages.${system}.default
    pkgs.wineWowPackages.waylandFull
    pkgs.winetricks
    pkgs.r2modman
    pkgs.prismlauncher
    pkgs.linuxConsoleTools
    pkgs.vkbasalt
  ];
}
