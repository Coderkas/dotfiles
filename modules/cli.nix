{
  config,
  customPkgs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.cli;
  inherit (config.machine)
    owner
    theme
    name
    platform
    ;
  inherit (customPkgs.packages.${platform}) nvfim;
in
{
  options.machine.cli.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.enableBase;
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      hjem.users.${owner}.xdg.config.files = {
        "bat/config".text = "--theme ${theme.bat}";

        "bottom/bottom.toml".text = ''
          [styles]
          theme = "${theme.bottom}"
        '';
      };

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
          settings.theme = theme.bat;
          extraPackages = [
            pkgs.bat-extras.batdiff
            pkgs.bat-extras.batgrep
            pkgs.bat-extras.batman
            pkgs.bat-extras.batpipe
          ];
        };

        fzf.fuzzyCompletion = true;

        fish = {
          enable = true;
          useBabelfish = true;
          interactiveShellInit = /* sh */ ''
            set fish_greeting
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
        yazi = {
          enable = true;
          settings = {
            yazi = {
              mgr.show_hidden = true;
              plugin.prepend_previewers = [
                {
                  name = "*.tar*";
                  run = "piper --format=url -- ${lib.getExe pkgs.gnutar} tf \"$1\"";
                }
                {
                  name = "*.csv";
                  run = "piper -- ${lib.getExe pkgs.bat} -p --color=always \"$1\"";
                }
                {
                  name = "*.md";
                  run = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dark \"$1\"";
                }
              ];
            };
            keymap = {
              mgr.prepend_keymap = [
                {
                  on = "<C-d>";
                  run = "plugin diff";
                  desc = "Diff the selected with the hovered file";
                }
                {
                  on = "f";
                  run = "plugin jump-to-char";
                  desc = "Jump to char";
                }
                {
                  on = "F";
                  run = "filter --smart";
                  desc = "Filter files";
                }
                {
                  on = [
                    "g"
                    "."
                  ];
                  run = "cd ~/dotfiles";
                  desc = "Go to ~/dotfiles";
                }
                {
                  on = [
                    "g"
                    "s"
                  ];
                  run = "cd /nix/store";
                  desc = "Go to nix store";
                }
              ];
            };
          };
          initLua = pkgs.writeText "yazi-init.lua" ''
            require("full-border"):setup()
          '';
          plugins = {
            inherit (pkgs.yaziPlugins)
              diff
              full-border
              jump-to-char
              piper
              ;
          };
        };
        zoxide.enable = true;
      };

      environment = {
        extraOutputsToInstall = [ "shell_integration" ];
        sessionVariables = {
          MANPAGER = "nvim +Man!";
          VISUAL = "nvim";
          EDITOR = "nvim";

          FZF_DEFAULT_OPTS = "--style=full";
        };

        shellAliases = {
          ip = "ip --pretty --color";
          fzn = "nvim $(fzf)";
          fdn = "fd main -X nvim";
          nixc = "nh clean all";
          # add untracked files and rebuild system
          nixr = ''~/dotfiles/nix.sh 1 "${name}"'';
          # Update flake inputs, create commit and run system upgrade
          nixu = ''~/dotfiles/nix.sh 2 "${name}"'';
          dot = "z ~/dotfiles && fzn";
          nt = "z ~/Sync/Obsidian-Vault && fzn";
          gac = "git add . && git commit -m ";
          gc = "git commit -m ";
          dd = ''echo -e "\033[0;95mReminder:\033[0m caligula is also installed"; ${pkgs.coreutils-full}/bin/dd'';
          df = ''echo -e "\033[0;95mReminder:\033[0m dua is also installed"; ${pkgs.coreutils-full}/bin/df'';
          du = ''echo -e "\033[0;95mReminder:\033[0m dua is also installed"; ${pkgs.coreutils-full}/bin/du'';

          eza = "eza --icons auto --git -a --group-directories-first --color=always";
          ls = "eza";
          la = "eza -a";
          ll = "eza -l";
          lla = "eza -la";
          lt = "eza --tree";
        };

        systemPackages = [
          nvfim # nvf neovim package
          pkgs.unzip
          pkgs.curl
          pkgs.wget
          pkgs.ripgrep
          pkgs.fd
          pkgs.jq
          pkgs.eza

          pkgs.bottom
          pkgs.babelfish
          pkgs.fishPlugins.fzf-fish
          pkgs.fishPlugins.forgit
          (pkgs.fishPlugins.fifc.overrideAttrs (old: {
            src = pkgs.fetchFromGitHub {
              owner = "gazorby";
              repo = "fifc";
              rev = "a01650cd432becdc6e36feeff5e8d657bd7ee84a";
              hash = "sha256-Ynb0Yd5EMoz7tXwqF8NNKqCGbzTZn/CwLsZRQXIAVp4=";
            };
          }))
        ];
      };
    })
    (lib.mkIf config.machine.enableDesktop {
      hjem.users.${owner}.xdg.config.files."fastfetch/config.jsonc" = {
        enable = config.machine.enableDesktop;
        generator = lib.generators.toJSON { };
        value = {
          display = {
            separator = " ";
            key.width = 17;
          };
          logo = {
            source = "linux";
            padding.top = 1;
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

      programs.direnv = {
        enable = true;
        settings.global = {
          warn_timeout = "15s";
          hide_env_diff = true;
        };
      };

      environment.systemPackages = [
        # Extracting things
        pkgs.p7zip
        pkgs.unrar
        pkgs.cabextract
        # Multimedia
        pkgs.ffmpeg
        pkgs.viu
        pkgs.yt-dlp
        # Latex/Markdown
        pkgs.glow
        pkgs.tectonic-unwrapped
        pkgs.biber
        pkgs.texliveBasic
        # File type detection and pdf rendering for i.e. yazi
        pkgs.file
        pkgs.poppler-utils

        pkgs.tlrc # Official rust tldr client
        pkgs.caligula # Better dd in rust
        pkgs.dua # Disk usage analyzer
        pkgs.numbat # Calculator/math scripting
        pkgs.fastfetch
      ];
    })
  ];
}
