{
  config,
  lib,
  pkgs,
  ...
}:
{
  machine.theme = lib.mkIf (config.machine.themeName == "Gruvbox") {
    cursor = "Capitaine Cursors (Gruvbox)";
    cursor_size = 24;
    icons = "Gruvbox-Plus-Dark";
    font = "JetBrainsMono Nerd Font";
    gtk = "Gruvbox-Dark";
    qt = "Gruvbox-Dark-Brown";
    kvantum = "${pkgs.gruvbox-kvantum}/share/Kvantum/Gruvbox-Dark-Brown";
    kitty = "gruvbox-dark-hard";
    ghostty = "Gruvbox Dark Hard";
    btop = "gruvbox_dark_v2";
    nvim = "gruvbox";
    bat = "gruvbox-dark";
    ttyColors = [
      "1d2021"
      "cc241d"
      "98971a"
      "d79921"
      "458588"
      "b16286"
      "689d6a"
      "a89984"
      "928374"
      "fb4934"
      "b8bb26"
      "fabd2f"
      "83a598"
      "d3869b"
      "8ec07c"
      "ebdbb2"
    ];

    zathura = ''
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

    rofi = ''
      * {
        background:     #282828FF;
        background-alt: #353535FF;
        foreground:     #EBDBB2FF;
        selected:       #83A598FF;
        active:         #B8BB26FF;
        urgent:         #FB4934FF;
      }
    '';

    pkgs = [
      pkgs.gruvbox-kvantum
      pkgs.gruvbox-gtk-theme
      pkgs.gruvbox-plus-icons
      pkgs.capitaine-cursors-themed
    ];
  };
}
