{
  config,
  lib,
  self,
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
          path = lib.mkForce [ ];
          serviceConfig.ExecStart = "notify-send -i ${self}/assets/chug.png 'Reminder' 'Stay hydrated!'; mpv ${self}/assets/poi.mp3 --volume=100";
        };
        rsi-reminder = {
          path = lib.mkForce [ ];
          serviceConfig.ExecStart = "notify-send -i ${self}/assets/peek.png 'Reminder' 'Posture check!'; mpv ${self}/assets/poi.mp3 --volume=100";
        };
        shutdown-reminder = {
          path = lib.mkForce [ ];
          serviceConfig.ExecStart = "notify-send -i /home/${cfg.owner}/dotfiles/assets/stare.png -u critical 'Attention' 'If you dont shutdown now you are gonna regret it in 9 hours!'; mpv /home/${cfg.owner}/dotfiles/assets/panic.ogg --volume=100";
        };
      };

      timers = {
        hydrate-reminder = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          timerConfig.OnCalendar = "*-*-* *:30:00";
        };
        rsi-reminder = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          timerConfig.OnCalendar = "hourly";
        };
        shutdown-reminder = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          timerConfig.OnCalendar = "*-*-* 02:00:00";
        };
      };

      targets.tray = {
        description = "System Tray target";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
