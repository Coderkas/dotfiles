{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) platform owner;
  inherit (inputs.walker.packages.${platform}) walker;
  inherit (inputs.elephant.packages.${platform}) elephant-with-providers;
in
{
  config = lib.mkIf (cfg.enableDesktop && cfg.runner.name == "walker") {
    hjem.users.${owner}.xdg.config.files = {
      "walker/config.toml".text = /* toml */ ''
        selection_wrap = true
        [keybinds]
        close = [ "Escape", "ctrl c" ]
        next = [ "Down", "ctrl n" ]
        previous = [ "Up", "ctrl p" ]
        left = [ "Left" ]
        right = [ "Right" ]
        down = [ "Down", "ctrl n" ]
        up = ["Up", "ctrl p" ]
        toggle_exact = [ "ctrl e" ]
        resume_last_query = [ "ctrl r" ]
        page_down = [ "Page_Down", "ctrl d" ]
        page_up = [ "Page_Up", "ctrl u" ]
        show_actions = [ "alt j" ]

        [providers]
        default = [
          "desktopapplications",
          "runner",
        ]

        [[providers.prefixes]]
        prefix = "?"
        provider = "providerlist"
        [[providers.prefixes]]
        prefix = "="
        provider = "calc"
      '';
      "elephant/desktopapplications.toml".text = /* toml */ ''
        launch_prefix = "systemd-run --user"
        window_integration = true
        single_instance_apps = [
          "discord",
          "steam"
        ]
        blacklist = [ "firefox" ]
      '';
      "elephant/websearch.toml".text = /* toml */ ''
        engines_as_actions = false
        entries = [
          { name = "DDG", default = true, prefix= "", url = "https://duckduckgo.com/?q=%TERM%" },
          { name = "Youtube", default = false, prefix= "yt:", url = "https://youtube.com/results?search_query=%TERM%" },
          { name = "Nix Options", default = false, prefix= "no:", url = "https://search.nixos.org/options?channel=unstable&query=%TERM%" },
          { name = "Nix Packages", default = false, prefix= "np:", url = "https://search.nixos.org/packages?channel=unstable&query=%TERM%" },
          { name = "X in Y", default = false, prefix= "xy:", url = "https://learnxinyminutes.com/%TERM%" },
          { name = "Wikipedia", default = false, prefix= "wiki:", url = "https://en.wikipedia.org/w/index.php?search=%TERM%" },
          { name = "Anilist", default = false, prefix= "ani:", url = "https://anilist.co/search/anime?search=%TERM%" },
        ]
      '';
      "elephant/providers/desktopapplications.so".source =
        "${elephant-with-providers}/lib/elephant/providers/desktopapplications.so";
      "elephant/providers/menus.so".source = "${elephant-with-providers}/lib/elephant/providers/menus.so";
      "elephant/providers/providerlist.so".source =
        "${elephant-with-providers}/lib/elephant/providers/providerlist.so";
      "elephant/providers/runner.so".source =
        "${elephant-with-providers}/lib/elephant/providers/runner.so";
      "elephant/providers/websearch.so".source =
        "${elephant-with-providers}/lib/elephant/providers/websearch.so";
      "elephant/providers/calc.so".source = "${elephant-with-providers}/lib/elephant/providers/calc.so";
      "elephant/providers/bookmarks.so".source =
        "${elephant-with-providers}/lib/elephant/providers/bookmarks.so";
    };

    machine.runner.commands = ''
      $menu = ${lib.getExe' walker "walker"}
      $bmenu = ${lib.getExe' walker "walker"} -m websearch
    '';

    systemd.user.services = {
      walker-daemon = {
        after = [
          "graphical-session.target"
          "elephant-daemon.service"
        ];
        description = "Walker service";
        partOf = [
          "graphical-session.target"
          "elephant-daemon.service"
        ];
        path = lib.mkForce [ ];
        wantedBy = [
          "graphical-session.target"
          "elephant-daemon.service"
        ];
        serviceConfig = {
          ExecStart = "${lib.getExe' walker "walker"} --gapplication-service";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
      elephant-daemon = {
        after = [ "graphical-session.target" ];
        description = "Elephant service";
        partOf = [ "graphical-session.target" ];
        path = lib.mkForce [ ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe' elephant-with-providers "elephant"}";
          Restart = "on-failure";
          RestartSec = 1;
          ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
        };

        restartTriggers = [ config.environment.systemPackages ];
      };
    };

    environment.systemPackages = [
      walker
      elephant-with-providers
    ];
  };
}
