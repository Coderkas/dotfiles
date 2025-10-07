{
  inputs,
  nvfim,
  pkgs,
  system,
  ...
}:
{
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = true;
    };

    nano.enable = false;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 2";
      };
      flake = "/home/lorkas/dotfiles";
    };

    fish.enable = true;
  };

  environment.systemPackages = [
    # nvf neovim package
    nvfim.neovim
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
    # Flake linter
    inputs.flint.packages.${system}.flint
  ];
}
