{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) owner;

  mimeapps = {
    addedAssociations = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "text/json" = "nvim.desktop";
      "text/html" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "text/xml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "application/yaml" = "nvim.desktop";
      "application/toml" = "nvim.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/ror2mm" = "r2modman.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "text/plain" = "nvim.desktop";
      "text/json" = "nvim.desktop";
      "text/html" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "text/xml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "application/yaml" = "nvim.desktop";
      "application/toml" = "nvim.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/epub+zip" = "org.pwmt.zathura.desktop";
      "image/apng" = "oculante.desktop";
      "image/bmp" = "oculante.desktop";
      "image/avif" = "oculante.desktop";
      "image/gif" = "oculante.desktop";
      "image/vnd.microsoft.icon" = "oculante.desktop";
      "image/jpeg" = "oculante.desktop";
      "image/png" = "oculante.desktop";
      "image/svg+xml" = "oculante.desktop";
      "image/tiff" = "oculante.desktop";
      "image/webp" = "oculante.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/midi" = "mpv.desktop";
      "audio/x-midi" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/webm" = "mpv.desktop";
      "audio/3gpp" = "mpv.desktop";
      "audio/3gpp2" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/mp2t" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/3gpp2" = "mpv.desktop";
    };
  };
in
{
  config = lib.mkIf config.machine.enableDesktop {
    xdg = {
      mime = {
        enable = true;
        inherit (mimeapps) addedAssociations defaultApplications;
      };
      icons.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config.common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };

    hjem.users.${owner}.xdg.config.files = {
      "mimeapps.list" = {
        generator = lib.generators.toINI { };
        value = {
          "Added Associations" = mimeapps.addedAssociations;
          "Default Associations" = mimeapps.defaultApplications;
        };
      };
    };

    environment = {
      pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];

      systemPackages = [
        pkgs.xdg-utils
      ];
    };
  };
}
