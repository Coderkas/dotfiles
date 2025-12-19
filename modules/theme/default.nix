{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  gtkConf = {
    gtk-cursor-theme-name = cfg.theme.cursor;
    gtk-cursor-theme-size = cfg.theme.cursor_size;
    gtk-font-name = cfg.theme.font;
    gtk-icon-theme-name = cfg.theme.icons;
    gtk-theme-name = cfg.theme.gtk;
    gtk-im-module = "fcitx";
  };

  gtkBookmarks = ''
    file:///home/${owner}/Downloads Downloads
    file:///home/${owner}/Documents Documents
    file:///home/${owner}/Music Music
    file:///home/${owner}/Pictures Pictures
    file:///home/${owner}/Videos Videos
  '';

  inherit (cfg) owner;
in
{
  imports = [ ./gruvbox.nix ];

  options.machine = {
    themeName = lib.mkOption {
      type = lib.types.enum [ "Gruvbox" ];
    };
    theme = lib.mkOption {
      type = lib.types.attrs;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableBase {
      console.colors = cfg.theme.ttyColors; # Colors for tty
    })
    (lib.mkIf cfg.enableDesktop {
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = cfg.theme.gtk;
            icon-theme = cfg.theme.icons;
          };
        }
      ];

      services.dbus.packages = [ pkgs.gnome-settings-daemon ];

      hjem.users.${owner} = {
        files = {
          ".gtkrc-2.0" = {
            generator = lib.generators.toKeyValue {
              mkKeyValue =
                k: v:
                let
                  v' = if (lib.isString v) then ''"${v}"'' else toString v;
                in
                "${k}=${v'}";
            };
            value = gtkConf;
          };

          ".gtk-bookmarks".text = gtkBookmarks;

          ".Xresources".text = ''
            Xcursor.size: ${toString cfg.theme.cursor_size}
            Xcursor.theme: ${cfg.theme.cursor}
          '';
        };

        xdg.config.files = {
          "gtk-3.0/settings.ini" = {
            generator = lib.generators.toINI { };
            value = {
              Settings = gtkConf // {
                gtk-application-prefer-dark-theme = true;
              };
            };
          };

          "gtk-4.0/settings.ini" = {
            generator = lib.generators.toINI { };
            value = {
              Settings = gtkConf;
            };
          };

          "gtk-3.0/bookmarks".text = gtkBookmarks;

          "Kvantum/kvantum.kvconfig".text = ''
            [General]
            theme=${cfg.theme.qt}
          '';
          "Kvantum/${cfg.theme.qt}".source = cfg.theme.kvantum;
          "kdeglobals".text = ''
            [General]
            theme=${cfg.theme.qt}
          '';
        };
      };

      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "kvantum";
      };

      users.users.${owner}.packages = cfg.theme.pkgs;

      environment = {
        systemPackages = cfg.theme.pkgs;
        sessionVariables = {
          GTK2_RC_FILES = "${config.hjem.users.${owner}.directory}/.gtkrc-2.0";
          GTK_THEME = cfg.theme.gtk;
          GDK_BACKEND = "wayland,x11,*";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          XCURSOR_THEME = cfg.theme.cursor;
          XCURSOR_SIZE = cfg.theme.cursor_size;
          HYPERCURSOR_THEME = cfg.theme.cursor;
          HYPERCURSOR_SIZE = cfg.theme.cursor_size;
        };
      };
    })
  ];
}
