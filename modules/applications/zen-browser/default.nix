{
  config,
  inputs,
  lib,
  pkgs,
  tack-src,
  ...
}:
let
  cfg = config.machine.zen-browser;
  inherit (config.machine) platform owner desktop;
  primaryBrowser = desktop.browser.name;

  zen-browser-git = inputs.zen-browser.packages.${platform}.twilight;

  mapExtensions = profilePath: [
    {
      name = profilePath + "uBlock0@raymondhill.net.xpi";
      value.source = tack-src.ublock;
    }
    {
      name = profilePath + "firefox@betterttv.net.xpi";
      value.source = tack-src.betterttv;
    }
    {
      name = profilePath + "addon@darkreader.org.xpi";
      value.source = tack-src.darkreader;
    }
    {
      name = profilePath + "vpn@proton.ch.xpi";
      value.source = tack-src.proton-vpn;
    }
    {
      name = profilePath + "{6b733b82-9261-47ee-a595-2dda294a4d08}.xpi";
      value.source = tack-src.yomitan;
    }
    {
      name = profilePath + "{762f9885-5a13-4abd-9c77-433dcd38b8fd}.xpi";
      value.source = tack-src.return-youtube-dislikes;
    }
    {
      name = profilePath + "keepassxc-browser@keepassxc.org.xpi";
      value.source = tack-src.keepassxc-browser;
    }
    {
      name = profilePath + "{d7742d87-e61d-4b78-b8a1-b469842139fa}.xpi";
      value.source = tack-src.vimium-ff;
    }
  ];
in
{
  options.machine.zen-browser.enable = lib.mkEnableOption "Zen-browser with extensions";
  config = lib.mkIf (cfg.enable || (desktop.enable && primaryBrowser == "zen-browser")) {
    machine.desktop.browser.command = "${zen-browser-git}/bin/zen-twilight";

    hjem.users.${owner}.xdg.config.files = {
      "zen/profiles.ini".source = ./config/profiles.ini;
      "zen/ImmersionProfile/user.js".source = ./config/user.js;
      "zen/ImmersionProfile/search.json.mozlz4" = {
        source = ./config/search.json.mozlz4;
        type = "copy";
        permissions = "644";
      };
      "zen/ImmersionProfile/prefs.js" = {
        source = ./config/user.js;
        type = "copy";
        permissions = "644";
      };
      "zen/ImmersionProfile/extensions.json" = {
        source = ./config/extensions.json;
        type = "copy";
        permissions = "644";
      };
      "zen/ImmersionProfile/extension-preferences.json" = {
        source = ./config/extension-preferences.json;
        type = "copy";
        permissions = "644";
      };

      "zen/PrimaryProfile/user.js".source = ./config/user.js;
      "zen/PrimaryProfile/search.json.mozlz4" = {
        source = ./config/search.json.mozlz4;
        type = "copy";
        permissions = "644";
      };
      "zen/PrimaryProfile/prefs.js" = {
        source = ./config/user.js;
        type = "copy";
        clobber = false;
        permissions = "644";
      };
      "zen/PrimaryProfile/extensions.json" = {
        source = ./config/extensions.json;
        type = "copy";
        permissions = "644";
      };
      "zen/PrimaryProfile/extension-preferences.json" = {
        source = ./config/extension-preferences.json;
        type = "copy";
        permissions = "644";
      };
    }
    // lib.listToAttrs (
      (mapExtensions "zen/PrimaryProfile/extensions/")
      ++ (mapExtensions "zen/ImmersionProfile/extensions/")
    );

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
