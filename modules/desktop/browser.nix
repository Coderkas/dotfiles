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
      "05a3f11dcbdj6s6c70x7hanqrpdv35lia4ia490qh0clljylmbsw"
    )
    (mkExtension "firefox@betterttv.net" "betterttv"
      "1njdg0hpw6qb1swlbi58ik8y516kw6ybh2cvdi4dv613jl0hj2l0"
    )
    (mkExtension "addon@darkreader.org" "darkreader"
      "1gj455hd0nw2idssbs7cmpxkg1kbjafq18n718rfx0yg5wpl46i6"
    )
    (mkExtension "vpn@proton.ch" "proton-vpn-firefox-extension"
      "0iy1m9i8dp09pm9hhf25an7bfyigr1f3spsxqc13265a36idw07k"
    )
    (mkExtension "{6b733b82-9261-47ee-a595-2dda294a4d08}" "yomitan"
      "0ydb7mzxyxfz05788wk0pccazql5qwrpk0xwpgmpq5jwsxz5jsw4"
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
