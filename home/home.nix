{
  pkgs,
  ...
}:
{
  imports = [ ./desktop.nix ];

  home = {
    username = "lorkas";
    homeDirectory = "/home/lorkas";
    stateVersion = "24.05";

    # Actually unnecessary because enableShellIntegration is true by default which provides its value to all other shell.enable*Integration options.
    # Sets enableShellIntegration in all other options to that value.
    shell = {
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    keyboard = {
      layout = "us,de";
      variant = ",qwerty";
      options = "grp:super_space_toggle,ctrl:nocaps";
    };
  };

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs = {
    man.generateCaches = false; # because we do that ourselves in system/default.nix
    bash = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      historyControl = [
        "ignoreboth"
        "erasedups"
      ];
      historyIgnore = [
        "exit"
        "poweroff"
      ];
      bashrcExtra = "export PROMPT_COMMAND='history -a'";
    };

    fish.enable = true;

    bat = {
      enable = true;
      config.theme = "gruvbox-dark";
      extraPackages = [
        pkgs.bat-extras.batdiff
        pkgs.bat-extras.batgrep
        pkgs.bat-extras.batman
        pkgs.bat-extras.batpipe
      ];
    };

    eza = {
      enable = true;
      extraOptions = [
        "-a"
        "--group-directories-first"
        "--color=always"
      ];
      git = true;
      icons = "auto";
    };

    fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "linux";
          padding.top = 1;
        };
        display = {
          separator = " ";
          key.width = 17;
        };
        modules = [
          "title"
          "os"
          "kernel"
          "packages"
          "shell"
          "terminal"
          "terminalfont"
          "theme"
          "wm"
          "cpu"
          "gpu"
          "memory"
          "board"
          "break"
          "colors"
        ];
      };
    };

    fzf = {
      enable = true;
      defaultOptions = [ "--style=full" ];
    };

    bottom = {
      enable = true;
      settings.styles.theme = "gruvbox";
    };
  };

  services = {
    gnome-keyring.enable = true;
    udiskie = {
      enable = true;
      automount = true;
    };
  };
}
