{ pkgs, nvfim, ... }:
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

  # Documentation
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
  };

  # Hardware stuff
  hardware = {
    bluetooth.enable = true;
    wirelessRegulatoryDatabase = true;
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

  environment.systemPackages = [
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
  ];
}
