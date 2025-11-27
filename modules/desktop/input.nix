{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.machine) theme;
in
{
  config = lib.mkMerge [
    (lib.mkIf config.machine.enableBase {
      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us,de,jp";
        variant = ",qwerty,";
        options = "grp:win_space_toggle,ctrl:nocaps";
      };
    })

    (lib.mkIf config.machine.enableDesktop {
      # Configure IME/Input method
      i18n = {
        inputMethod = {
          type = "fcitx5";
          enable = true;
          fcitx5 = {
            waylandFrontend = true;
            addons = [
              pkgs.fcitx5-mozc-ut
              pkgs.fcitx5-gtk
              pkgs.kdePackages.fcitx5-qt
              pkgs.fcitx5-material-color
            ];
            ignoreUserConfig = false;
            settings = {
              inputMethod = {
                "Groups/0" = {
                  "Name" = "Default";
                  "Default Layout" = "us";
                  "DefaultIM" = "mozc";
                };
                "Groups/0/Items/0".Name = "keyboard-us";
                "Groups/0/Items/1".Name = "keyboard-de";
                "Groups/0/Items/2".Name = "mozc";
                "GroupOrder"."0" = "Default";
              };
              globalOptions = {
                "Hotkey" = {
                  "TriggerKeys" = "";
                  "EnumarateWithTriggerKeys" = "True";
                  "AltTriggerKeys" = "";
                  "EnumerateSkipFirst" = "False";
                  "EnumerateGroupForwardKeys" = "";
                  "EnumerateGroupBackwardKeys" = "";
                  "ModifierOnlyKeyTimeout" = 250;
                };
                "Hotkey/EnumerateForwardKeys"."0" = "Super+space";
                "Hotkey/EnumerateBackwardKeys"."0" = "Shift+Super+space";
                "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
                "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
                "Hotkey/PrevPage"."0" = "Up";
                "Hotkey/NextPage"."0" = "Down";
                "Hotkey/PrevCandidate"."0" = "Shift+Tab";
                "Hotkey/NextCandidate"."0" = "Tab";
                "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
                "Behavior" = {
                  "ActiveByDefault" = "False";
                  "resetStateWhenFocusIn" = "No";
                  "ShareInputState" = "All";
                  "PreeditEnabledByDefault" = "True";
                  "ShowInputMethodInformation" = "True";
                  "showInputMethodInformationWhenFocusIn" = "False";
                  "CompactInputMethodInformation" = "True";
                  "ShowFirstInputMethodInformation" = "True";
                  "DefaultPageSize" = 5;
                  "OverrideXkbOption" = "True";
                  "CustomXkbOption" = "";
                  "EnabledAddons" = "";
                  "DisabledAddons" = "";
                  "PreloadInputMethod" = "True";
                  "AllowInputMethodForPassword" = "False";
                  "ShowPreeditForPassword" = "False";
                  "AutoSavePeriod" = 30;
                };
              };

              addons = {
                classicui.globalSection = {
                  "Vertical Candidate List" = "True";
                  "WheelForPaging" = "True";
                  "Font" = ''"${theme.font} 10"'';
                  "MenuFont" = ''"${theme.font} 10"'';
                  "TrayFont" = ''"${theme.font} Bold 10"'';
                  "TrayOutlineColor" = "#000000";
                  "TrayTextColor" = "#ffffff";
                  "PreferTextIcon" = "False";
                  "ShowLayoutNameInIcon" = "True";
                  "UseInputMethodLanguageToDisplayText" = "True";
                  "Theme" = "default-dark";
                  "DarkTheme" = "default-dark";
                  "UseDarkTheme" = "True";
                  "UseAccentColor" = "True";
                  "PerScreenDPI" = "False";
                  "ForceWaylandDPI" = "0";
                  "EnableFractionalScale" = "True";
                };

                keyboard = {
                  globalSection = {
                    "PageSize" = 5;
                    "EnableEmoji" = "True";
                    "EnableQuickPhraseEmoji" = "True";
                    "Choose Modifier" = "Alt";
                    "EnableHintByDefault" = "False";
                    "UseNewComposeBehavior" = "True";
                    "EnableLongPress" = "False";
                  };
                  sections = {
                    "PrevCandidate"."0" = "Shift+Tab";
                    "NextCandidate"."0" = "Tab";
                    "One Time Hint Trigger"."0" = "Control+Alt+J";
                  };
                };

                mozc.globalSection = {
                  "InitialMode" = "Hiragana";
                  "InputState" = "Follow Global Configuration";
                  "Vertical" = "True";
                  "ExpandMode" = "On Focus";
                  "PreeditCursorPositionAtBeginning" = "False";
                  "ExpandKey" = "Control+Alt+H";
                };

                notifications.globalSection."HiddenNotifications" = "";

                unicode = {
                  globalSection = { };
                  sections = {
                    "TriggerKey"."0" = "Control+Alt+Shift+U";
                    "DirectUnicodeMode"."0" = "Control+Shift+U";
                  };
                };

                waylandim.globalSection = {
                  "DetectApplication" = "True";
                  "PreferKeyEvent" = "True";
                  "PersistentVirtualKeyboard" = "False";
                };

                xcb.globalSection = {
                  "Allow Overriding System XKB Settings" = "True";
                  "AlwaysSetToGroupLayout" = "True";
                };
              };
            };
          };
        };
      };

      systemd.user.services.fcitx5-daemon = {
        description = "Fcitx5 input method editor";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.ExecStart = "${lib.getExe config.i18n.inputMethod.package}";
        wantedBy = [ "graphical-session.target" ];
        path = lib.mkForce [ ];
      };

      environment.sessionVariables = {
        SDL_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "ibus";
        QT_IM_MODULE = "fcitx";
      };
    })
  ];
}
