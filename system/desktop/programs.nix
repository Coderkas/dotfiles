{ pkgs, ... }:
{
  programs = {
    java.enable = true;
    seahorse.enable = true;
    kdeconnect.enable = true;
    thunderbird.enable = true;
  };

  environment.systemPackages = with pkgs; [
    signal-desktop
    keepassxc
    firefox
    # maybe necessary for some notification stuff?
    libnotify
    discord
    obsidian
    gimp
    inkscape-with-extensions
    helvum
    gnome-clocks
    element-desktop

    # Gnome files with plugin for previewer
    nautilus
    sushi
  ];
}
