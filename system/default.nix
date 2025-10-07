{
  pkgs,
  host_name,
  lib,
  config,
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
    ./nix.nix
  ];

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
  documentation = {
    man = {
      # Instead of using the default stuff we use our own.
      # This builds a derivation named man-paths, which takes the combined package lists of nixos and home-manager,
      # makes sure to install the man output for them and links all of the content under /share/man of each pkg into the directory of the derivation.
      # Now we have a single man_db.conf instead of one for nixos and .manpath for home.
      man-db.manualPages = pkgs.buildEnv {
        name = "man-paths";
        paths = config.environment.systemPackages ++ config.home-manager.users.lorkas.home.packages;
        pathsToLink = [ "/share/man" ];
        extraOutputsToInstall = [ "man" ];
        ignoreCollisions = true;
      };
      generateCaches = true;
    };
    doc.enable = false;
    info.enable = false;
  };

  # Hardware stuff
  hardware = {
    bluetooth.enable = true;
    wirelessRegulatoryDatabase = true;
    enableAllFirmware = lib.mkDefault true;
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
  };
}
