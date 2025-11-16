{ config, lib, ... }:
let
  cfg = config.machine.audio;
in
{
  options.machine.audio.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.enableDesktop;
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      lowLatency.enable = config.machine.enableGaming; # Pipewire goes brr thanks to nix-gaming by fufexan
    };

    environment.shellAliases = {
      helvum = "nix run nixpkgs#helvum";
    };
  };
}
