{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) platform;

  mkExtension = name: shortId: sha256: {
    name = ".zen/PrimaryProfile/extensions/${name}.xpi";
    value = {
      source = builtins.fetchurl {
        url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
        inherit sha256;
      };
    };
  };

  extensions = [
    (mkExtension "uBlock0@raymondhill.net" "ublock-origin"
      "1kvj2kwwiih7yqiirqha7xfvip4vzrgyqr4rjjhaiyi5ibkcsnvq"
    )
    (mkExtension "firefox@betterttv.net" "betterttv"
      "1f56alvrj6z5694wbj4nw16113j2b58rxba1jyncqdb230k93vkz"
    )
    (mkExtension "addon@darkreader.org" "darkreader"
      "1p8gmypj43qzsl2daj7facqz5qqy0npf1k4fa8k65lm4wjhgass9"
    )
    (mkExtension "vpn@proton.ch" "proton-vpn-firefox-extension"
      "0dz44jg7rm1xrdhngab0p8y7ac94m0pmaak1j9ichwcvyddd079q"
    )
    (mkExtension "{6b733b82-9261-47ee-a595-2dda294a4d08}" "yomitan"
      "1h6arqgyis809zxy3zxrk3xlwby0af3j5wc536f774js64fvha7h"
    )
    (mkExtension "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" "return-youtube-dislikes"
      "17m1if7lna1rhawixbj0d1ap2bv1qc2qw7qn8dsm6xijx5y9fcrd"
    )
    (mkExtension "keepassxc-browser@keepassxc.org" "keepassxc-browser"
      "0fb1my82sb42zfqdvfgmqvi8bgib3cmv25z37ap3d3cninn27rdy"
    )
    (mkExtension "{d7742d87-e61d-4b78-b8a1-b469842139fa}" "vimium-ff"
      "0wqlb4iik74h1jilkif20zl6br3l3rfvjq2fdsic4f8rnhf8c6rc"
    )
  ];
in
{
  config = lib.mkIf cfg.enableDesktop {
    hjem.users.${cfg.owner}.files = {
      ".zen/profiles.ini".text = ''
        [Profile0]
        Name=PrimaryProfile
        IsRelative=1
        Path=PrimaryProfile
        Default=1

        [Profile1]
        Name=ImmersionProfile
        IsRelative=1
        Path=ImmersionProfile
        Default=0

        [General]
        StartWithLastProfile=1
        Version=2
      '';

      ".zen/ImmersionProfile/user.js".source = ./user.js;
      ".zen/ImmersionProfile/search.json.mozlz4".source = ./search.json.mozlz4;
      ".zen/ImmersionProfile/extensions".source = "/home/${cfg.owner}/.zen/PrimaryProfile/extensions";

      ".zen/PrimaryProfile/user.js".source = ./user.js;
      ".zen/PrimaryProfile/search.json.mozlz4".source = ./search.json.mozlz4;
    }
    // lib.listToAttrs extensions;

    environment = {
      sessionVariables.BROWSER = "zen-twilight";
      systemPackages = [
        inputs.zen-browser.packages.${platform}.twilight
        #pkgs.firefox

        (pkgs.makeDesktopItem {
          name = "Immersion";
          desktopName = "Immersion";
          genericName = "Web Browser";
          icon = "zen-twilight";
          exec = "zen-twilight --name immersion --class immersion -P ImmersionProfile %U";
          terminal = false;
          mimeTypes = [
            "text/html"
            "text/xml"
          ];
          categories = [ "Network" ];
          extraConfig = {
            "StartupWMClass" = "immersion";
          };
        })
      ];
    };
  };
}
