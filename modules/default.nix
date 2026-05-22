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

    name = lib.mkOption {
      type = lib.types.nonEmptyStr;
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

  config = {
    assertions = [
      {
        assertion = cfg.owner != null;
        message = "owner is not set";
      }
      {
        assertion = cfg.name != null;
        message = "machine name is not set";
      }
      {
        assertion = cfg.platform != null;
        message = "platform is not set";
      }
      {
        assertion = cfg.cpu != null;
        message = "cpu is not set";
      }
      {
        assertion = cfg.desktop.enable == true && cfg.desktop.bar != null;
        message = "A bar should be set when running a desktop";
      }
      {
        assertion = cfg.desktop.enable == true && cfg.desktop.browser != null;
        message = "A browser should be set when running a desktop";
      }
      {
        assertion = cfg.desktop.enable == true && cfg.desktop.runner != null;
        message = "A runner should be set when running a desktop";
      }
      {
        assertion = cfg.desktop.enable == true && cfg.desktop.terminal != null;
        message = "A terminal should be set when running a desktop";
      }
    ];
  };
}
