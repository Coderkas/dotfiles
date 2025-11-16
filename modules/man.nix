{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.machine.enableBase {
    documentation = {
      man = {
        # Instead of using the default stuff we use our own.
        # This builds a derivation named man-paths, which takes the combined package lists of nixos and home-manager,
        # makes sure to install the man output for them and links all of the content under /share/man of each pkg into the directory of the derivation.
        # Now we have a single man_db.conf instead of one for nixos and .manpath for home.
        man-db.manualPages = pkgs.buildEnv {
          name = "man-paths";
          paths = config.environment.systemPackages;
          pathsToLink = [ "/share/man" ];
          extraOutputsToInstall = [ "man" ];
          ignoreCollisions = true;
        };
        generateCaches = true;
      };
      doc.enable = false;
      info.enable = false;
    };
  };
}
