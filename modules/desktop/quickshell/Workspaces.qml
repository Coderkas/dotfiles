//@ pragma IconTheme Gruvbox-Plus-Dark
//@ pragma UseQApplication
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property list<HyprlandWorkspace> spaces: Hyprland.workspaces.values
    readonly property list<string> kanji: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "windowtitlev2")
                Hyprland.refreshToplevels();
        }
    }

    Repeater {
        model: root.spaces.length < 10 ? root.spaces.length : 10

        RowLayout {
            required property int index
            readonly property HyprlandWorkspace space: root.spaces[index]
            Text {
                color: Style.fg
                font.family: Style.font
                text: root.kanji[parent.index]
            }

            Repeater {
                model: parent.space.toplevels.values
                IconImage {
                    required property var modelData
                    height: Style.icon_size
                    width: Style.icon_size
                    source: Quickshell.iconPath(String(modelData.lastIpcObject.class), "xfce-unknown")
                }
            }
        }
    }
}
