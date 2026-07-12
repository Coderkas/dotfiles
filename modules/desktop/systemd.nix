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
  config = lib.mkIf cfg.desktop.enable {
    services.logind.settings.Login.KillUserProcesses = true;

    systemd.user = {
      services = {
        hydrate-reminder = {
          path = lib.mkForce [ ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [
              "${pkgs.libnotify}/bin/notify-send -i /home/${cfg.owner}/dotfiles/assets/chug.png 'Reminder' 'Stay hydrated!'"
              "${pkgs.ffmpeg}/bin/ffplay -loglevel warning -nodisp -autoexit /home/${cfg.owner}/dotfiles/assets/poi.mp3"
            ];
          };
        };
        rsi-reminder = {
          path = lib.mkForce [ ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [
              "${pkgs.libnotify}/bin/notify-send -i /home/${cfg.owner}/dotfiles/assets/peek.png 'Reminder' 'Posture check!'"
              "${pkgs.ffmpeg}/bin/ffplay -loglevel warning -nodisp -autoexit /home/${cfg.owner}/dotfiles/assets/poi.mp3"
            ];
          };
        };
        shutdown-reminder = {
          path = lib.mkForce [ ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [
              "${pkgs.libnotify}/bin/notify-send -i /home/${cfg.owner}/dotfiles/assets/stare.png -u critical 'Attention' 'If you dont shutdown now you are gonna regret it in 9 hours!'"
              "${pkgs.ffmpeg}/bin/ffplay -loglevel warning -nodisp -autoexit /home/${cfg.owner}/dotfiles/assets/panic.ogg"
            ];
          };
        };
        tray-delay = {
          after = [ "graphical-session.target" ];
          before = [ "tray.target" ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils-full}/bin/sleep 2";
          };
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
