{
  config,
  lib,
  ...
}:
let
  cfg = config.machine;
  inherit (cfg) owner;
in
{
  config = lib.mkIf cfg.enableDesktop {
    systemd.user = {
      services = {
        hydrate-reminder = {
          path = lib.mkForce [ ];
          script = ''notify-send -i /home/${owner}/dotfiles/assets/chug.png "Reminder" "Stay hydrated!"; mpv /home/${owner}/dotfiles/assets/poi.mp3 --volume=100'';
          startAt = "*-*-* *:30:00";
        };
        rsi-reminder = {
          path = lib.mkForce [ ];
          script = ''notify-send -i /home/${owner}/dotfiles/assets/peek.png "Reminder" "Posture check!"; mpv /home/${owner}/dotfiles/assets/poi.mp3 --volume=100'';
          startAt = "hourly";
        };
        shutdown-reminder = {
          path = lib.mkForce [ ];
          script = ''notify-send -i /home/${owner}/dotfiles/assets/stare.png -u critical "Attention" "If you dont shutdown now you are gonna regret it in 9 hours!"; mpv /home/${owner}/dotfiles/assets/panic.ogg --volume=100'';
          startAt = "*-*-* 02:00:00";
        };
      };

      targets.tray = {
        description = "System Tray target";
        requires = [ "graphical-session-pre.target" ];
      };

      tmpfiles.users.${owner}.rules = [
        "r! /home/${owner}/.local/state/nvf/lsp.log"
        "r! /home/${owner}/.local/state/nvf/luasnip.log"
      ];
    };
  };
}
