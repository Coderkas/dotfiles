{ pkgs, ... }:
{
  programs = {
    java.enable = true;
    seahorse.enable = true;
    kdeconnect.enable = true;
    thunderbird.enable = true;
  };

  environment.systemPackages = [
    pkgs.signal-desktop
    pkgs.keepassxc
    pkgs.firefox
    # maybe necessary for some notification stuff?
    pkgs.libnotify
    pkgs.discord
    pkgs.obsidian
    pkgs.gimp
    pkgs.inkscape-with-extensions
    pkgs.helvum
    pkgs.gnome-clocks
    pkgs.element-desktop

    # Gnome files with plugin for previewer
    pkgs.nautilus
    pkgs.sushi
  ];
}
