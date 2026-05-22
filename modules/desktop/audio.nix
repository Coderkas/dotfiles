{
  config,
  lib,
  ...
}:
let
  cfg = config.machine;
in
{
  config = lib.mkIf cfg.desktop.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;

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
  };
}
