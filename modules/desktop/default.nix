{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  hyprpicker-git = inputs.hyprpicker.packages.${cfg.platform}.hyprpicker;
in
{
  imports = [
    ./audio.nix
    ./gaming.nix
    ./hardware.nix
    ./input.nix
    ./systemd.nix
    ./virtualisation.nix
    ./wayland.nix
    ./xdg.nix
  ];

  config = lib.mkIf cfg.desktop.enable {
    hjem.users.${cfg.owner}.xdg.config.files = {
      "zathura/zathurarc".text = cfg.theme.zathura;
      "mpv/mpv.conf".text = "volume=20";
    };

    fonts.packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-color-emoji
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.iosevka-term
      pkgs.nerd-fonts.caskaydia-cove
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.symbols-only
      pkgs.ipaexfont
      pkgs.jigmo
    ];

    programs = {
      bandwhich.enable = true; # top for sockets/connections
      dconf.enable = true;
      thunderbird.enable = true;
      java.enable = true;

      direnv = {
        enable = true;
        settings.global = {
          warn_timeout = "15s";
          hide_env_diff = true;
        };
      };
    };

    services = {
      printing = {
        enable = true;
        drivers = [
          # Covers most printers to fix errors
          pkgs.splix
          pkgs.gutenprint
          pkgs.hplip
        ];
      };

      devmon.enable = true;
      gnome.sushi.enable = true;
      gvfs.enable = true;

      dbus.packages = [
        pkgs.nautilus
        pkgs.file-roller
        pkgs.gnome-clocks
        pkgs.zathura
      ];
    };

    environment = {
      sessionVariables = {
        GST_PLUGIN_PATH = "/run/current-system/sw/lib/gstreamer-1.0/";
      };
      shellAliases = {
        dd = ''echo -e "\033[0;95mReminder:\033[0m caligula is also installed"; ${pkgs.coreutils-full}/bin/dd'';
        df = ''echo -e "\033[0;95mReminder:\033[0m dua is also installed"; ${pkgs.coreutils-full}/bin/df'';
        du = ''echo -e "\033[0;95mReminder:\033[0m dua is also installed"; ${pkgs.coreutils-full}/bin/du'';
      };

      systemPackages = [
        pkgs.gst_all_1.gstreamer
        pkgs.gst_all_1.gst-plugins-base
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        # Extracting things
        pkgs._7zip-zstd-rar
        pkgs.unrar
        pkgs.cabextract
        pkgs.file-roller
        # Multimedia
        pkgs.ffmpeg
        pkgs.viu
        pkgs.yt-dlp
        # Latex/Markdown
        pkgs.glow
        pkgs.tectonic-unwrapped
        pkgs.biber
        pkgs.texliveBasic
        # File type detection and pdf rendering for i.e. yazi
        pkgs.file
        pkgs.poppler-utils

        pkgs.caligula # Better dd in rust
        pkgs.dua # Disk usage analyzer
        pkgs.numbat # Calculator/math scripting
        pkgs.termscp # terminal for ftp, scp, etc.
        pkgs.sqlite
        pkgs.lazysql
        pkgs.nurl # Nix url resolver
        pkgs.systemctl-tui

        pkgs.zathura
        (pkgs.mpv.override {
          mpv-unwrapped = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; };
        })
        pkgs.keepassxc
        pkgs.discord
        pkgs.obsidian
        pkgs.gnome-clocks
        pkgs.oculante # image viewer
        # Gnome files with plugin for previewer
        pkgs.nautilus
        pkgs.proton-vpn
        pkgs.qbittorrent
        pkgs.wireguard-tools
        hyprpicker-git

        pkgs.man-pages # add some extra man pages
      ];
    };
  };
}
