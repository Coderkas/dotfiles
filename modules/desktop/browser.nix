{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) platform;

  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "force_installed";
    };
  };

  extensions = [
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "betterttv" "firefox@betterttv.net")
    (extension "darkreader" "addon@darkreader.org")
    (extension "proton-vpn-firefox-extension" "vpn@proton.ch")
    (extension "yomitan" "{6b733b82-9261-47ee-a595-2dda294a4d08}")
    (extension "return-youtube-dislikes" "{762f9885-5a13-4abd-9c77-433dcd38b8fd}")
  ];
in
{
  config = lib.mkIf (!cfg.enableDesktop) {
    programs.firefox = {
      enable = true;
      package = inputs.zen-browser.packages.${platform}.twilight;
      policies = {
        DisableTelemetry = true;
        ExtensionSettings = builtins.listToAttrs extensions;

        SearchEngines = {
          Default = "ddg";
        };
      };

      preferences = {
        "extensions.autoDisableScopes" = 0;
        "extensions.pocket.enabled" = false;
      };

      languagePacks = [
        "en-US"
        "de"
        "ja"
      ];
    };
  };
}
