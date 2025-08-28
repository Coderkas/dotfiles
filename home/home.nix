{
  pkgs,
  host_name,
  nvfim,
  ...
}:
{
  imports = [ ./desktop.nix ];

  home = {
    username = "lorkas";
    homeDirectory = "/home/lorkas";
    stateVersion = "24.05";

    sessionVariables = {
      MANPAGER = "${nvfim.neovim.outPath}/bin/nvim +Man!";
      VISUAL = "${nvfim.neovim.outPath}/bin/nvim";
      EDITOR = "${nvfim.neovim.outPath}/bin/nvim";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    # Actually unnecessary because enableShellIntegration is true by default which provides its value to all other shell.enable*Integration options.
    # Sets enableShellIntegration in all other options to that value.
    shell = {
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    shellAliases = {
      ip = "ip --pretty --color";
      ls = "eza";
      cd = "z";
      grep = "rg";
      cat = "bat";
      fvi = "nvim $(fzf)";
      nixc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      # add untracked files and rebuild system
      nixr = "~/dotfiles/nix.sh 1 '${host_name}'";
      # Update flake inputs, create commit and run system upgrade
      nixu = "~/dotfiles/nix.sh 2 '${host_name}'";
      dot = "z ~/dotfiles && fvi";
      nt = "z ~/Sync/Obsidian-Vault && fvi";
      gaa = "git add .";
      gac = "git add . && git commit -m ";
      gc = "git commit -m ";
    };

    keyboard = {
      layout = "us,de";
      variant = "qwerty";
      options = "grp:super_space_toggle,ctrl:nocaps";
    };

    extraOutputsToInstall = [
      "doc"
      "info"
      "devdoc"
    ];
  };

  manual = {
    json.enable = true;
    manpages.enable = true;
  };

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs = {
    home-manager.enable = true;
    man.generateCaches = true;
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

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        fastfetch
      '';
      plugins = [
        {
          name = "fzf.fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
        {
          name = "forgit";
          inherit (pkgs.fishPlugins.forgit) src;
        }
      ];

    };

    starship = {
      enable = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
      };
    };

    fd = {
      enable = true;
      hidden = true;
      extraOptions = [ "--no-ignore" ];
      ignores = [ ".git/" ];
    };

    ripgrep = {
      enable = true;
      arguments = [ "-uu" ];
    };

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
      fileWidgetOptions = [
        "--preview 'bat -pp --color=always {}'"
        "--bind 'focus:transform-header:file --brief {}'"
      ];
      changeDirWidgetOptions = [
        "--preview 'bat -pp --color=always {}'"
        "--bind 'focus:transform-header:file --brief {}'"
      ];
      colors = {
        fg = "#ebdbb2";
        bg = "#282828";
        hl = "#fabd2f";
        "fg+" = "#ebdbb2";
        "bg+" = "#3c3836";
        "hl+" = "#fabd2f";
        info = "#83a598";
        prompt = "#bdae93";
        spinner = "#fabd2f";
        pointer = "#83a598";
        marker = "#fe8019";
        header = "#665c54";
      };
    };

    git = {
      enable = true;
      userEmail = "92148778+Coderkas@users.noreply.github.com";
      userName = "Coderkas";
      extraConfig.credential.helper = [ "libsecret" ];
    };

    btop = {
      enable = true;
      settings.color_theme = "gruvbox_dark_v2";
    };

    ssh.enable = true;
    jq.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
    pistol.enable = true;
  };

  services = {
    gnome-keyring.enable = true;

    udiskie = {
      enable = true;
      automount = true;
    };
  };
}
