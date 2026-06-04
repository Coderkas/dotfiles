{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.zen-browser;
  primaryBrowser = config.machine.desktop.browser.name;
  inherit (config.machine) platform owner;

  zen-browser-git = inputs.zen-browser.packages.${platform}.twilight;

  extensionsJSON = builtins.readFile ./extensions.json;
  extensionsList = builtins.fromJSON extensionsJSON;

  extensionsMapped =
    profile:
    (map (ext: {
      name = ".zen/${profile}/extensions/${ext.name}";
      value.source = builtins.fetchurl { inherit (ext) url sha256; };
    }) extensionsList);

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
      "1swzhiwsfjygp0cznrajijwh2mv1i2ayzc0bncq4h09czjhqixs7"
    )
    (mkExtension "firefox@betterttv.net" "betterttv"
      "18l57rd1yp341cqhf1y1dj3d1k1qqdb65xmy79g05q1cggh27dgv"
    )
    (mkExtension "addon@darkreader.org" "darkreader"
      "19r8jlrl5aiy3qq6wzndsgbwakja60gyhgd2dzdzhnhalqkr3gdh"
    )
    (mkExtension "vpn@proton.ch" "proton-vpn-firefox-extension"
      "00x79kfs7jcldx7m3yadk2pabkxlfzndg8p4r6kbmgvpilbn03zm"
    )
    (mkExtension "{6b733b82-9261-47ee-a595-2dda294a4d08}" "yomitan"
      "0ffi6npg0fr99k5sdnmvb6wqkhgfg72jsa5fc505myc4ajqhz5b1"
    )
    (mkExtension "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" "return-youtube-dislikes"
      "17m1if7lna1rhawixbj0d1ap2bv1qc2qw7qn8dsm6xijx5y9fcrd"
    )
    (mkExtension "keepassxc-browser@keepassxc.org" "keepassxc-browser"
      "0s25gk0559fviskakfnfg07a0dbs63n9gkwvgvis4fi9197cbyad"
    )
    (mkExtension "{d7742d87-e61d-4b78-b8a1-b469842139fa}" "vimium-ff"
      "15nixab67dxah8kzqhdl8yn9yh31kqaq35xib89fjyhfb1kjl7hk"
    )
  ];
in
{
  options.machine.zen-browser.enable = lib.mkEnableOption "Enable zen-browser with extensions";
  config = lib.mkIf (cfg.enable || primaryBrowser == "zen-browser") {
    machine.desktop.browser.command = "${zen-browser-git}/bin/zen-twilight";

    hjem.users.${owner}.files = {
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

      ".zen/ImmersionProfile/user.js".source = ./config/user.js;
      ".zen/ImmersionProfile/search.json.mozlz4".source = ./config/search.json.mozlz4;
      ".zen/ImmersionProfile/extensions".source = "/home/${owner}/.zen/PrimaryProfile/extensions";

      ".zen/PrimaryProfile/user.js".source = ./config/user.js;
      ".zen/PrimaryProfile/search.json.mozlz4".source = ./config/search.json.mozlz4;
    }
    // lib.listToAttrs ((extensionsMapped "PrimaryProfile") ++ (extensionsMapped "ImmersionProfile"));

    environment = {
      sessionVariables.BROWSER = "zen-twilight";
      systemPackages = [
        zen-browser-git

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
