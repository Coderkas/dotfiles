{ pkgs, ... }:
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,de";
    variant = ",qwerty";
    options = "grp:win_space_toggle,ctrl:nocaps";
  };

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
        ];
        settings = {
          inputMethod = {
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "mozc";
            };
            "Groups/0/Items/0" = {
              "Name" = "keyboard-us";
              "Layout" = null;
            };
            "Groups/0/Items/1" = {
              "Name" = "keyboard-de";
              "Layout" = null;
            };
            "Groups/0/Items/2" = {
              "Name" = "mozc";
              "Layout" = "gb";
            };
            "GroupOrder"."0" = "Default";
          };
          globalOptions = {
            "Hotkey" = {
              "TriggerKeys" = null;
              "EnumarateWithTriggerKeys" = "True";
              "AltTriggerKeys" = null;
              "EnumerateSkipFirst" = "False";
              "EnumerateGroupForwardKeys" = null;
              "EnumerateGroupBackwardKeys" = null;
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
              "OverrideXkbOption" = "False";
              "CustomXkbOption" = null;
              "EnabledAddons" = null;
              "DisabledAddons" = null;
              "PreloadInputMethod" = "True";
              "AllowInputMethodForPassword" = "False";
              "ShowPreeditForPassword" = "False";
              "AutoSavePeriod" = 30;
            };
          };

          addons = {
            classicui.globalSection = {
              "Vertical Candidate List" = "False";
              "WheelForPaging" = "True";
              "Font" = "Sans 10";
              "MenuFont" = "Sans 10";
              "TrayFont" = "Sans Bold 10";
              "TrayOutlineColor" = "#000000";
              "TrayTextColor" = "#ffffff";
              "PreferTextIcon" = "False";
              "ShowLayoutNameInIcon" = "True";
              "UseInputMethodLanguageToDisplayText" = "True";
              "Theme" = "default-dark";
              "DarkTheme" = "default-dark";
              "UseDarkTheme" = "False";
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
                "Hint Trigger"."0" = "Control+Alt+H";
                "One Time Hint Trigger"."0" = "Control+Alt+J";
                "LongPressBlocklist" = {
                  "0" = "konsole";
                  "1" = "org.kde.konsole";
                };
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

            notifications.globalSection."HiddenNotifications" = null;

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
}
