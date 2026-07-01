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

    security = {
      rtkit = {
        enable = true;
        args = [
          "--scheduling-policy=FIFO"
          "--our-realtime-priority=89"
          "--max-realtime-priority=88"
          "--min-nice-level=-19"
          "--rttime-usec-max=2000000"
          "--users-max=100"
          "--processes-per-user-max=1000"
          "--threads-per-user-max=10000"
          "--actions-burst-sec=10"
          "--actions-per-burst-max=1000"
          "--canary-cheep-msec=30000"
          "--canary-watchdog-msec=60000"
        ];
      };
      pam.loginLimits = [
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
        {
          domain = "@pipewire";
          type = "-";
          item = "rtprio";
          value = "95";
        }
        {
          domain = "@pipewire";
          type = "-";
          item = "nice";
          value = "-19";
        }
        {
          domain = "@pipewire";
          type = "-";
          item = "memlock";
          value = "4194304";
        }
      ];
    };
  };
}
