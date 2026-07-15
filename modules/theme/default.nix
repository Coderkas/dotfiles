{
  config,
  lib,
  ...
}:
let
  cfg = config.machine;

  gtkINI = ''
    		[Settings]
        gtk-cursor-theme-name=${cfg.theme.cursor}
        gtk-cursor-theme-size=${toString cfg.theme.cursor_size}
        gtk-font-name=${cfg.theme.font}
        gtk-icon-theme-name=${cfg.theme.icons}
        gtk-im-module="fcitx"
        gtk-theme-name=${cfg.theme.gtk}
  '';

  gtkBookmarks = ''
    file:///home/${owner}/Downloads Downloads
    file:///home/${owner}/Documents Documents
    file:///home/${owner}/Music Music
    file:///home/${owner}/Pictures Pictures
    file:///home/${owner}/Videos Videos
  '';

  qtct = ''
    [Appearance]
    custom_palette=false
    icon_theme=${cfg.theme.icons}
    standard_dialogs=xdgdesktopportal
    style=kvantum
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

  config = lib.mkIf cfg.desktop.enable {
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            cursor-size = lib.gvariant.mkInt32 cfg.theme.cursor_size;
            cursor-theme = cfg.theme.cursor;
            font-name = cfg.theme.font;
            icon-theme = cfg.theme.icons;
            gtk-theme = cfg.theme.gtk;
            gtk-im-module = "fcitx";
          };
        };
      }
    ];

    hjem.users.${owner} = {
      files = {
        ".gtkrc-2.0".text = ''
          gtk-cursor-theme-name="${cfg.theme.cursor}"
          gtk-cursor-theme-size=${toString cfg.theme.cursor_size}
          gtk-font-name="${cfg.theme.font}"
          gtk-icon-theme-name="${cfg.theme.icons}"
          gtk-im-module="fcitx"
          gtk-theme-name="${cfg.theme.gtk}"
        '';

        ".gtk-bookmarks".text = gtkBookmarks;

        ".Xresources".text = ''
          Xcursor.size: ${toString cfg.theme.cursor_size}
          Xcursor.theme: ${cfg.theme.cursor}
        '';
      };

      xdg = {
        config.files = {
          "gtk-3.0/settings.ini".text = gtkINI + ''
            gtk-application-prefer-dark-theme=true
          '';

          "gtk-4.0/settings.ini".text = gtkINI;

          "gtk-3.0/bookmarks".text = gtkBookmarks;

          "Kvantum/kvantum.kvconfig".text = ''
            [General]
            theme=${cfg.theme.qt}
          '';
          "Kvantum/${cfg.theme.qt}".source = cfg.theme.kvantum;
          "kdeglobals".text = ''
            ${cfg.theme.kde}

            [General]
            theme=${cfg.theme.qt}

            [Icons]
            Theme=${cfg.theme.icons}

            [KDE]
            widgetStyle=Breeze
          '';

          "qt5ct/qt5ct.conf".text = qtct;
          "qt6ct/qt6ct.conf".text = qtct;
        };
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
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        XCURSOR_THEME = cfg.theme.cursor;
        XCURSOR_SIZE = cfg.theme.cursor_size;
        HYPRCURSOR_THEME = cfg.theme.cursor;
        HYPRCURSOR_SIZE = cfg.theme.cursor_size;
      };
    };
  };
}
