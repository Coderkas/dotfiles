{
  pkgs,
  inputs,
  lib,
  system,
  ...
}:

{

  imports = [
    ./hyprland.nix
    ./gaming.nix
  ];

  home = {
    pointerCursor = {
      x11.enable = true;
      gtk.enable = true;
      package = pkgs.capitaine-cursors-themed;
      name = "Capitaine Cursors (Gruvbox)";
      size = 24;
    };

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      XDG_SESSION_TYPE = "wayland";
      # not adding ",x11,windos" causes issues with easy anti cheat
      SDL_VIDEODRIVER = "wayland,x11,windows";
      BROWSER = "firefox";
    };

    packages = [
      inputs.ags.packages.${system}.io
      # So that the power menu is in path and gets recognized by rofi
      pkgs.rofi-power-menu
      # To make rofi firefox bookmark script work
      pkgs.sqlite
    ];
  };

  xdg = {
    mimeApps = {
      enable = true;
      associations.added = {
        "application/pdf" = [ "firefox.desktop" ];
      };
      defaultApplications = {
        "x-scheme-handler/ror2mm" = [ "r2modman.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
      };
    };

    desktopEntries = {
      immersion = {
        name = "Immersion";
        genericName = "Web Browser";
        icon = "firefox";
        exec = "firefox --name immersion --class immersion -P Immersion %U";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "text/html"
          "text/xml"
        ];
        settings = {
          "StartupWMClass" = "immersion";
        };
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gruvbox-gtk-theme;
      name = "Gruvbox-Dark";
    };
    iconTheme = {
      package = pkgs.gruvbox-plus-icons;
      name = "Gruvbox-Plus-Dark";
      # Backup in case gruvbox breaks again
      #package = pkgs.adwaita-icon-theme;
      #name = "Adwaita";
    };
    cursorTheme = {
      package = pkgs.capitaine-cursors-themed;
      name = "Capitaine Cursors (Gruvbox)";
      size = 24;
    };
    font.name = "CascadiaCode";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  programs = {
    # maybe get rid of later
    kitty = {
      enable = false;
      themeFile = "GruvboxMaterialDarkHard";
      extraConfig = ''
        window_margin_width 10

        tab_bar_style fade
        tab_fade 1
      '';
      font = {
        name = "JetBrainsMono Nerd Font";
      };
    };

    ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        theme = "GruvboxDarkHard";
        command = "fish";
        window-padding-x = 15;
        window-padding-y = 10;
        font-size = 11;
        window-theme = "ghostty";
        adw-toolbar-style = "flat";
        gtk-wide-tabs = false;
        gtk-tabs-location = "bottom";
        gtk-gsk-renderer = "default";
        gtk-single-instance = true;
        gtk-custom-css = "~/dotfiles/home/ghostty.css";
        auto-update = "off";
      };
    };

    zathura = {
      enable = true;
      extraConfig = ''
        set notification-error-bg       "rgba(40,40,40,1)"     # bg
        set notification-error-fg       "rgba(251,73,52,1)"    # bright:red
        set notification-warning-bg     "rgba(40,40,40,1)"     # bg
        set notification-warning-fg     "rgba(250,189,47,1)"   # bright:yellow
        set notification-bg             "rgba(40,40,40,1)"     # bg
        set notification-fg             "rgba(184,187,38,1)"   # bright:green

        set completion-bg               "rgba(80,73,69,1)"     # bg2
        set completion-fg               "rgba(235,219,178,1)"  # fg
        set completion-group-bg         "rgba(60,56,54,1)"     # bg1
        set completion-group-fg         "rgba(146,131,116,1)"  # gray
        set completion-highlight-bg     "rgba(131,165,152,1)"  # bright:blue
        set completion-highlight-fg     "rgba(80,73,69,1)"     # bg2

        # Define the color in index mode
        set index-bg                    "rgba(80,73,69,1)"     # bg2
        set index-fg                    "rgba(235,219,178,1)"  # fg
        set index-active-bg             "rgba(131,165,152,1)"  # bright:blue
        set index-active-fg             "rgba(80,73,69,1)"     # bg2

        set inputbar-bg                 "rgba(40,40,40,1)"     # bg
        set inputbar-fg                 "rgba(235,219,178,1)"  # fg

        set statusbar-bg                "rgba(80,73,69,1)"     # bg2
        set statusbar-fg                "rgba(235,219,178,1)"  # fg

        set highlight-color             "rgba(250,189,47,0.5)" # bright:yellow
        set highlight-active-color      "rgba(254,128,25,0.5)" # bright:orange

        set default-bg                  "rgba(40,40,40,1)"     # bg
        set default-fg                  "rgba(235,219,178,1)"  # fg
        set render-loading              true
        set render-loading-bg           "rgba(40,40,40,1)"     # bg
        set render-loading-fg           "rgba(235,219,178,1)"  # fg

        # Recolor book content's color
        set recolor-lightcolor          "rgba(40,40,40,1)"     # bg
        set recolor-darkcolor           "rgba(235,219,178,1)"  # fg
        set recolor                     "true"
        set recolor-keephue             "true"                 # keep original color
      '';
    };

    ags = {
      enable = true;
      configDir = ./ags;
      extraPackages = [
        inputs.ags.packages.${system}.battery
        inputs.ags.packages.${system}.hyprland
        inputs.ags.packages.${system}.tray
        inputs.ags.packages.${system}.wireplumber
        inputs.ags.packages.${system}.apps
      ];
    };

    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      cycle = true;
      extraConfig = {
        show-icons = true;
        window-match-fields = "class";
      };
      location = "center";
      modes = [
        "drun"
        "run"
        "window"
        "combi"
      ];
      plugins = [
        pkgs.rofi-calc
        pkgs.rofi-power-menu
      ];
      terminal = lib.getExe pkgs.ghostty;
      font = "JetBrainsMono Nerd Font 10";
      theme = ./rofi-theme.rasi;
    };

    mpv.enable = true;
    yt-dlp.enable = true;
    texlive.enable = true;
    obs-studio.enable = true;
  };

  services = {
    udiskie = {
      notify = true;
    };

    dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          width = "0 300";
          height = 100;
          origin = "top-center";
          corner_radius = 5;
          background = "#282828";
          foreground = "#ebdbb2";
          highlight = "#fabd2f";
          frame_color = "#ebdbb2";
          frame_width = 1;
          gap_size = 5;
          font = "JetBrains Mono Nerd Font Medium 10";
        };

        urgency_critical = {
          foreground = "#cc241d";
          highlight = "#d65d0e";
        };
      };
    };
  };
}
