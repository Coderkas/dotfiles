{
  pkgs,
  host_name,
  nvfim,
  ...
}:
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./networking.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./users.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
      trusted-users = [ "lorkas" ];
      download-buffer-size = 500000000;
      auto-optimise-store = true;
      builders-use-substitutes = true;
    };
  };

  # Colors for tty
  console.colors = [
    "3c3836"
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
    "fbf1c7"
  ];

  # Documentation
  documentation.man.generateCaches = true;

  # Hardware stuff
  hardware = {
    bluetooth.enable = true;
    wirelessRegulatoryDatabase = true;
    enableAllFirmware = true;
  };

  fonts.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    pkgs.noto-fonts-color-emoji
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.iosevka-term
    pkgs.nerd-fonts.caskaydia-cove
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
    pkgs.ipaexfont
    pkgs.jigmo
  ];

  environment = {
    sessionVariables = {
      MANPAGER = "nvim +Man!";
      VISUAL = "nvim";
      EDITOR = "nvim";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    shellAliases = {
      ip = "ip --pretty --color";
      ls = "eza";
      cd = "z";
      grep = "rg";
      cat = "bat";
      fzn = "nvim $(fzf)";
      fdn = "fd main -X nvim";
      nixc = "nh clean all";
      # add untracked files and rebuild system
      nixr = ''~/dotfiles/nix.sh 1 "${host_name}"'';
      # Update flake inputs, create commit and run system upgrade
      nixu = ''~/dotfiles/nix.sh 2 "${host_name}"'';
      dot = "z ~/dotfiles && fzn";
      nt = "z ~/Sync/Obsidian-Vault && fzn";
      gaa = "git add .";
      gac = "git add . && git commit -m ";
      gc = "git commit -m ";
      dd = ''echo -e "\033[0;95mReminder:\033[0m caligula is also installed"; ${pkgs.coreutils-full}/bin/dd'';
      df = ''echo -e "\033[0;95mReminder:\033[0m dua is also installed"; ${pkgs.coreutils-full}/bin/df'';
      du = ''echo -e "\033[0;95mReminder:\033[0m dua is also installed"; ${pkgs.coreutils-full}/bin/du'';
    };

    systemPackages = [
      # nvf neovim package
      nvfim.neovim
      # nix options and package searcher
      pkgs.manix
      # Official rust tldr client
      pkgs.tlrc
      # Extracting things
      pkgs.unzip
      pkgs.p7zip
      pkgs.unrar
      pkgs.wget
      pkgs.cabextract
      pkgs.ffmpeg
      # Latex/markdown
      pkgs.glow
      pkgs.tectonic-unwrapped
      pkgs.biber
      # Probing for usb devices and stuff
      pkgs.usbutils
      # File type detection and pdf rendering for other applications like yazi
      pkgs.file
      pkgs.poppler_utils
      # terminal image renderer via kitty protocol
      pkgs.viu
      # better dd in rust
      pkgs.caligula
      # disk usage analyzer
      pkgs.dua
    ];
  };
}
