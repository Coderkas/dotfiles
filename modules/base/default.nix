{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
in
{
  imports = [
    ./boot.nix
    ./locales.nix
    ./man.nix
    ./networking.nix
    ./nix.nix
    ./ssh.nix
    ./users.nix
  ];

  config = {
    machine = {
      yazi.enable = true;
      neovim.enable = true;
    };

    console.colors = cfg.theme.ttyColors; # Colors for tty

    hjem.users.${cfg.owner}.xdg.config.files = {
      "btop/btop.conf".text = ''
        color_theme = "${cfg.theme.btop}"
        vim_keys = True
      '';
    };

    hardware = {
      enableAllFirmware = lib.mkDefault true;
      cpu = {
        intel.updateMicrocode = lib.mkDefault (cfg.cpu == "intel");
        amd.updateMicrocode = lib.mkDefault (cfg.cpu == "amd");
      };

      deviceTree = lib.mkIf (cfg.cpu == "pi") {
        enable = true;
        filter = "*rpi-4-*.dtb";
      };
    };

    fonts.packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-color-emoji
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.iosevka-term
      pkgs.nerd-fonts.caskaydia-cove
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.symbols-only
      pkgs.ipaexfont
      pkgs.jigmo
    ];

    programs = {
      bash = {
        enable = true;
        completion.enable = true;
        vteIntegration = true;
        interactiveShellInit = /* sh */ ''
          export PROMPT_COMMAND='history -a'
          HISTCONTROL=ignoreboth:erasedups
          HISTFILESIZE=100000
          HISTIGNORE=exit:poweroff:shutdown
          HISTSIZE=10000

          shopt -s histappend
          shopt -s checkwinsize
          shopt -s extglob
          shopt -s globstar
          shopt -s checkjobs

          source ${pkgs.fzf}/share/fzf/key-bindings.bash
        '';
      };

      bat = {
        enable = true;
        settings.theme = cfg.theme.bat;
        extraPackages = [
          pkgs.bat-extras.batdiff
          pkgs.bat-extras.batgrep
          pkgs.bat-extras.batpipe
        ];
      };

      fzf.fuzzyCompletion = true;

      fish = {
        enable = true;
        useBabelfish = true;
        interactiveShellInit = /* sh */ ''
          set fish_greeting
          ${lib.getExe pkgs.tlrc} $(${lib.getExe pkgs.tlrc} -l | shuf -n 1)
        '';
      };

      git = {
        enable = true;
        config = {
          credential.helper = "libsecret";
          init.defaultBranch = "main";
          user = {
            email = "92148778+Coderkas@users.noreply.github.com";
            name = "Coderkas";
          };
        };
      };

      starship = {
        enable = true;
        transientPrompt.enable = true;
      };

      nano.enable = lib.mkForce false;
      zoxide.enable = true;
    };

    services = {
      dbus.implementation = "broker";

      # More scheduling stuff
      scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
        scheduler = "scx_bpfland";
      };

      fwupd.enable = true;
    };

    security.polkit.enable = true;

    environment = {
      extraOutputsToInstall = [ "shell_integration" ];
      variables = {
        PAGER = lib.mkForce "bat";
        SYSTEMD_LESS = lib.mkForce "FRSM";
      };
      sessionVariables = {
        PAGER = "bat";
        SYSTEMD_LESS = "FRSM";
        FZF_DEFAULT_OPTS = "--style=full";
      };

      shellAliases = {
        ip = "ip --pretty --color";
        gac = "git add . && git commit -m ";
        gc = "git commit -m ";

        eza = "eza --icons auto --git -a --group-directories-first --color=always";
        ls = "eza";
        la = "eza -a";
        ll = "eza -l";
        lla = "eza -la";
        lt = "eza --tree";
        cat = "bat";
      };

      systemPackages = [
        pkgs.unzip

        pkgs.curl
        pkgs.wget
        pkgs.inetutils

        pkgs.ripgrep
        pkgs.fd
        pkgs.jq
        pkgs.eza
        pkgs.btop

        pkgs.babelfish
        pkgs.fishPlugins.fzf-fish
        pkgs.fishPlugins.forgit
        (pkgs.fishPlugins.fifc.overrideAttrs (_: {
          src = pkgs.fetchFromGitHub {
            owner = "gazorby";
            repo = "fifc";
            rev = "a01650cd432becdc6e36feeff5e8d657bd7ee84a";
            hash = "sha256-Ynb0Yd5EMoz7tXwqF8NNKqCGbzTZn/CwLsZRQXIAVp4=";
          };
        }))
      ]
      ++ lib.optionals (cfg.cpu == "pi") [
        pkgs.libraspberrypi
        pkgs.raspberrypi-eeprom
      ];
    };
  };
}
