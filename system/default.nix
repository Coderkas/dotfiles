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

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    ipaexfont
    jigmo
  ];

  environment.systemPackages = with pkgs; [
    # nvf neovim package
    nvfim.neovim
    # nix options and package searcher
    manix
    # Official rust tldr client
    tlrc
    # Extracting things
    curl
    unzip
    p7zip
    unrar
    gnutar
    wget
    cabextract
    ffmpeg
    # Latex/markdown
    glow
    tectonic-unwrapped
    biber
    # Probing for usb devices and stuff
    usbutils
    # File type detection and pdf rendering for other applications like yazi
    file
    poppler_utils
  ];
}
