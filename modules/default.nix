{
  config,
  lib,
  ...
}:
let
  cfg = config.machine;
in
{
  imports = [
    ./applications
    ./base
    ./desktop
    ./theme
  ];

  options.machine = {
    desktop = {
      enable = lib.mkEnableOption "Enable desktop preset";
      bar = lib.mkOption {
        type = lib.types.enum [
          "quickshell"
          "ironbar"
        ];
      };
      browser = {
        name = lib.mkOption {
          type = lib.types.enum [
            "zen-browser"
          ];
        };
        command = lib.mkOption {
          type = lib.types.nonEmptyStr;
        };
      };
      runner = {
        name = lib.mkOption {
          type = lib.types.enum [
            "anyrun"
            "rofi"
            "walker"
          ];
        };
        commands = {
          menu = lib.mkOption {
            type = lib.types.nonEmptyStr;
          };
          web = lib.mkOption {
            type = lib.types.nonEmptyStr;
          };
        };
      };
      terminal = {
        name = lib.mkOption {
          type = lib.types.enum [
            "ghostty"
            "kitty"
          ];
        };
        command = lib.mkOption {
          type = lib.types.nonEmptyStr;
        };
      };

      primaryMonitor = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };
    };

    sessionWrapper = lib.mkOption {
      type = lib.types.package;
    };

    platform = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };

    cpu = lib.mkOption {
      type = lib.types.enum [
        "intel"
        "amd"
        "pi"
      ];
    };

    hasDedicatedGpu = lib.mkEnableOption "Enable gpu stuff";
  };
}
