pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property color bg: "#1d2021"
    readonly property color fg: "#ebdbb2"
    readonly property string font: "FiraCode Nerd Font"
    readonly property ShellScreen monitor: Quickshell.screens.length < 3 ? Quickshell.screens[0] : Quickshell.screens[1]
    readonly property real height: 30
    readonly property real icon_size: 15
}
