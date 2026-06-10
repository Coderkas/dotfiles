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
      name = "zen/${profile}/extensions/${ext.name}.xpi";
      value.source = builtins.fetchurl { inherit (ext) url sha256; };
    }) extensionsList);
in
{
  options.machine.zen-browser.enable = lib.mkEnableOption "Enable zen-browser with extensions";
  config = lib.mkIf (cfg.enable || primaryBrowser == "zen-browser") {
    machine.desktop.browser.command = "${zen-browser-git}/bin/zen-twilight";

    hjem.users.${owner}.xdg.config.files = {
      "zen/profiles.ini".source = ./config/profiles.ini;
      "zen/ImmersionProfile/user.js".source = ./config/user.js;
      "zen/ImmersionProfile/search.json.mozlz4" = {
        source = ./config/search.json.mozlz4;
        type = "copy";
        clobber = true;
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
        clobber = true;
        permissions = "644";
      };
      "zen/ImmersionProfile/extension-preferences.json" = {
        source = ./config/extension-preferences.json;
        type = "copy";
        clobber = true;
        permissions = "644";
      };
      "zen/ImmersionProfile/storage/default/moz-extension+++0a5c1077-6284-4a92-8c3f-03a448e29516^userContextId=4294967295" =
        {
          source = ./config/yomitan;
          type = "copy";
          clobber = true;
          permissions = "644";
        };
      "zen/ImmersionProfile/storage/default/moz-extension+++3b79b31b-3a1e-4175-a558-ebd5f7b633dc^userContextId=4294967295" =
        {
          source = ./config/ublock;
          type = "copy";
          clobber = true;
          permissions = "644";
        };

      "zen/PrimaryProfile/user.js".source = ./config/user.js;
      "zen/PrimaryProfile/search.json.mozlz4" = {
        source = ./config/search.json.mozlz4;
        type = "copy";
        clobber = true;
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
        clobber = true;
        permissions = "644";
      };
      "zen/PrimaryProfile/extension-preferences.json" = {
        source = ./config/extension-preferences.json;
        type = "copy";
        clobber = true;
        permissions = "644";
      };
      "zen/PrimaryProfile/storage/default/moz-extension+++0a5c1077-6284-4a92-8c3f-03a448e29516^userContextId=4294967295" =
        {
          source = ./config/yomitan;
          type = "copy";
          clobber = true;
          permissions = "644";
        };
      "zen/PrimaryProfile/storage/default/moz-extension+++3b79b31b-3a1e-4175-a558-ebd5f7b633dc^userContextId=4294967295" =
        {
          source = ./config/ublock;
          type = "copy";
          clobber = true;
          permissions = "644";
        };
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
