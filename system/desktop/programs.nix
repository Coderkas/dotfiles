{ pkgs, ... }:
{
  programs = {
    java.enable = true;
    seahorse.enable = true;
    kdeconnect.enable = true;

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        clang
        clang-tools
      ];
    };

    thunderbird.enable = true;
  };

  environment.systemPackages = with pkgs; [
    keepassxc
    firefox
    # maybe necessary for some notification stuff?
    libnotify
    discord
    obsidian
    libreoffice
    gimp
    helvum
    gnome-clocks
    element-desktop

    # Gnome files with plugin for previewer
    nautilus
    sushi
  ];
}
