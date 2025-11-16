{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine;
  hjem = inputs.hjem.packages.${cfg.platform};
in
{
  imports = [ inputs.hjem.nixosModules.default ];

  options.machine.owner = lib.mkOption {
    type = lib.types.nonEmptyStr;
  };

  config = lib.mkIf (cfg.owner != null) {
    users.users.${cfg.owner} = {
      isNormalUser = true;
      description = cfg.owner;
      createHome = true;
      home = "/home/${cfg.owner}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
      ]
      ++ lib.optionals cfg.enableDesktop [
        "audio"
        "video"
        "realtime"
      ];
    };

    hjem = {
      linker = hjem.smfh;
      users.${cfg.owner} = {
        enable = true;
        directory = "/home/${cfg.owner}";
        user = cfg.owner;
      };
    };
  };
}
