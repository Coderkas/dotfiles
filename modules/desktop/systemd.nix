{
  config,
  lib,
  ...
}:
let
  cfg = config.machine;
in
{
  config = lib.mkIf cfg.desktop.enable {
    services.logind.settings.Login.KillUserProcesses = true;

    systemd.user = {
      services = {
        hydrate-reminder = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          path = lib.mkForce [ ];
          script = ''notify-send -i /home/${cfg.owner}/dotfiles/assets/chug.png "Reminder" "Stay hydrated!"; mpv /home/${cfg.owner}/dotfiles/assets/poi.mp3 --volume=100'';
          startAt = "*-*-* *:30:00";
        };
        rsi-reminder = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          path = lib.mkForce [ ];
          script = ''notify-send -i /home/${cfg.owner}/dotfiles/assets/peek.png "Reminder" "Posture check!"; mpv /home/${cfg.owner}/dotfiles/assets/poi.mp3 --volume=100'';
          startAt = "hourly";
        };
        shutdown-reminder = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          path = lib.mkForce [ ];
          script = ''notify-send -i /home/${cfg.owner}/dotfiles/assets/stare.png -u critical "Attention" "If you dont shutdown now you are gonna regret it in 9 hours!"; mpv /home/${cfg.owner}/dotfiles/assets/panic.ogg --volume=100'';
          startAt = "*-*-* 02:00:00";
        };
      };

      targets.tray = {
        description = "System Tray target";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
      };

      tmpfiles.users.${cfg.owner}.rules = [
        "r! /home/${cfg.owner}/.local/state/nvf/lsp.log"
        "r! /home/${cfg.owner}/.local/state/nvf/luasnip.log"
      ];
    };
  };
}
