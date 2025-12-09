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
      alsa.support32Bit = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      #lowLatency.enable = config.machine.enableGaming; # Pipewire goes brr thanks to nix-gaming by fufexan

      extraConfig = {
        pipewire."99-default" = {
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              flags = [
                "ifexists"
                "nofail"
              ];
              args = {
                "nice.level" = -19;
                "rt.prio" = 95;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
            }
          ];
        };
      };
    };

    security.pam.loginLimits = [
      {
        domain = "@audio";
        type = "-";
        item = "rtprio";
        value = "95";
      }
      {
        domain = "@audio";
        type = "-";
        item = "nice";
        value = "-19";
      }
      {
        domain = "@audio";
        type = "-";
        item = "memlock";
        value = "4194304";
      }
    ];

    environment.shellAliases = {
      helvum = "nix run nixpkgs#helvum";
    };
  };
}
