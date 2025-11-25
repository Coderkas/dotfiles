{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.chaotic.nixosModules.default
    inputs.nix-gaming.nixosModules.pipewireLowLatency

    ./desktop
    ./hypr
    ./theme
    ./audio.nix
    ./boot.nix
    ./cli.nix
    ./gaming.nix
    ./hardware.nix
    ./locales.nix
    ./man.nix
    ./networking.nix
    ./nix.nix
    ./ssh.nix
    ./syncthing.nix
    ./systemd.nix
    ./users.nix
    ./virtualisation.nix
  ];

  options.machine = {
    enableBase = lib.mkEnableOption "";
    name = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
    platform = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.enableBase != null;
          message = "enableBase is not set";
        }
        {
          assertion = cfg.enableDesktop != null;
          message = "enableDesktop is not set";
        }
        {
          assertion = cfg.owner != null;
          message = "owner is not set";
        }
        {
          assertion = cfg.owner != null;
          message = "name is not set";
        }
        {
          assertion = cfg.owner != null;
          message = "platform is not set";
        }
      ];
    }
    (lib.mkIf cfg.enableBase {
      security.polkit.enable = true;

      fonts.packages = [
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
        pkgs.noto-fonts-color-emoji
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.iosevka-term
        pkgs.nerd-fonts.caskaydia-cove
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.symbols-only
        pkgs.ipaexfont
        pkgs.jigmo
      ];
    })
  ];
}
