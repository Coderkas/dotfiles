{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.audio;
in
{
  options.machine.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.machine.enableDesktop;
    };
    enableEasyEffects = lib.mkEnableOption "Enable Easy Effect";
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

    systemd.user.services.easyeffects = lib.mkIf cfg.enableEasyEffects {
      description = "Easyeffects";
      partOf = [
        "graphical-session.target"
        "tray.target"
      ];
      wantedBy = [
        "graphical-session.target"
        "tray.target"
      ];
      path = lib.mkForce [ ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.easyeffects} --service-mode -w";
      };
    };

    environment = {
      systemPackages = lib.optionals cfg.enableEasyEffects [ pkgs.easyeffects ];
      shellAliases = {
        helvum = "nix run nixpkgs#helvum";
      };
    };
  };
}
