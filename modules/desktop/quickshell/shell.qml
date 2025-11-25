//@ pragma IconTheme Gruvbox-Plus-Dark
//@ pragma UseQApplication
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root
    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm | dd.MM.yyyy")
    property list<HyprlandWorkspace> hypr_spaces: Hyprland.workspaces.values
    readonly property list<SystemTrayItem> tray_items: SystemTray.items.values

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "windowtitlev2")
                Hyprland.refreshToplevels();
        }
    }

    PanelWindow {
        screen: Style.monitor
        color: Style.bg

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Style.height

        Workspaces {
            anchors.right: focused.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: focused
            width: 800
            implicitHeight: Style.height
            anchors.centerIn: parent
            color: "transparent"
            Text {
                anchors.centerIn: parent
                function get_title() {
                    var title = Hyprland.activeToplevel?.title;
                    if (title == null)
                        return "";
                    else if (title.length > 60)
                        return title.slice(0, 60);
                    else
                        return title;
                }
                font.family: Style.font
                color: Style.fg
                text: get_title()
            }
        }

        TrayModule {
            anchors {
                right: _mic.left
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }

        Microphone {
            id: _mic
            anchors {
                right: _speaker.left
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }

        Speaker {
            id: _speaker
            anchors {
                right: time_date.left
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }

        Text {
            id: time_date
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: Style.fg
            font.family: Style.font
            text: root.time
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    component HyprSpaces: RowLayout {
        id: spaces_row
        property int spaces_length: root.hypr_spaces.length
        property list<string> kanji: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

        Repeater {
            model: parent.spaces_length < 10 ? parent.spaces_length : 10
            RowLayout {
                id: space_item
                required property int index
                readonly property HyprlandWorkspace hypr_space: root.hypr_spaces[index]
                Text {
                    color: Style.fg
                    font.family: Style.font
                    text: spaces_row.kanji[space_item.index]
                }
                Repeater {
                    model: space_item.hypr_space.toplevels.values
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

    component TrayModule: RowLayout {
        spacing: 10
        Repeater {
            model: root.tray_items
            ClickableIcon {
                id: tray_item
                required property var modelData
                source: modelData.icon
                area.onPressed: mouse => {
                    if (mouse.button == Qt.LeftButton)
                        modelData.activate();
                    else if (mouse.button == Qt.RightButton) {
                        tray_item_anchor.menu = modelData.menu;
                        console.log(Object.getOwnPropertyNames(modelData.menu));
                        tray_item_anchor.open();
                    } else if (mouse.button == Qt.MiddleButton)
                        modelData.secondaryActivate();
                }

                QsMenuAnchor {
                    id: tray_item_anchor
                    anchor {
                        item: tray_item
                        edges: Edges.Bottom | Edges.Right
                        gravity: Edges.Bottom | Edges.Left
                    }
                }
            }
        }
    }

    component Speaker: ClickableIcon {
        id: speaker
        readonly property PwNode _sink: Pipewire.defaultAudioSink
        property list<PwNode> nodes: Pipewire.nodes.values
        source: _sink.audio.muted ? Quickshell.iconPath("audio-volume-muted") : Quickshell.iconPath("audio-volume-high")
        PwObjectTracker {
            objects: [speaker._sink]
        }
        area.onPressed: mouse => {
            if (mouse.button == Qt.LeftButton)
                _sink.audio.muted = !_sink.audio.muted;
            else if (mouse.button == Qt.RightButton) {
                speaker_menu.visible = !speaker_menu.visible;
            }
        }

        PopupWindow {
            id: speaker_menu
            anchor {
                item: speaker
                edges: Edges.Bottom | Edges.Right
                gravity: Edges.Bottom | Edges.Left
            }
            implicitWidth: speaker_column.implicitWidth + 20
            implicitHeight: speaker_column.implicitHeight + 20
            color: "transparent"
            Rectangle {
                radius: 10
                color: Style.fg
                anchors.fill: parent
                Rectangle {
                    radius: 10
                    color: Style.bg
                    anchors.centerIn: parent
                    implicitWidth: parent.width - 2
                    implicitHeight: parent.height - 2
                }
            }

            ColumnLayout {
                id: speaker_column
                spacing: 5
                anchors.centerIn: parent
                Repeater {
                    model: speaker.nodes.filter(node => node.isSink && node.name && !node.isStream)

                    Rectangle {
                        id: highlight
                        required property var modelData
                        radius: 5
                        color: "#00FFFFFF"
                        Layout.minimumWidth: 300
                        Layout.minimumHeight: children[0].height + 10

                        Text {
                            anchors {
                                left: highlight.left
                                leftMargin: 10
                                verticalCenter: highlight.verticalCenter
                            }
                            PwObjectTracker {
                                objects: [highlight.modelData]
                            }
                            color: Style.fg
                            text: highlight.modelData.nickname
                        }

                        IconImage {
                            anchors {
                                right: highlight.right
                                rightMargin: 10
                                verticalCenter: highlight.verticalCenter
                            }
                            implicitSize: Style.icon_size
                            mipmap: true
                            source: Quickshell.iconPath("checkmark")
                            visible: highlight.modelData == speaker._sink
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true
                            onPressed: mouse => {
                                if (mouse.button == Qt.LeftButton) {
                                    Pipewire.preferredDefaultAudioSink = highlight.modelData;
                                    speaker_menu.visible = !speaker_menu.visible;
                                }
                            }
                            onEntered: () => {
                                highlight.color = "#11FFFFFF";
                            }
                            onExited: () => {
                                highlight.color = "#00FFFFFF";
                            }
                        }
                    }
                }
            }
        }
    }

    component Microphone: ClickableIcon {
        id: mic
        readonly property PwNode _source: Pipewire.defaultAudioSource
        source: _source.audio.muted ? Quickshell.iconPath("mic-off") : Quickshell.iconPath("mic-ready")
        PwObjectTracker {
            objects: [mic._source]
        }
        area.onPressed: mouse => {
            if (mouse.button == Qt.LeftButton)
                _source.audio.muted = !_source.audio.muted;
        }
    }

    component AudioModules: RowLayout {
        id: audio_row
        spacing: 20
        readonly property PwNode audio_sink: Pipewire.defaultAudioSink
        readonly property PwNode audio_source: Pipewire.defaultAudioSource
        property list<PwNode> audio_nodes: Pipewire.nodes.values

        ClickableIcon {
            id: speaker_item
            source: audio_row.audio_sink.audio.muted ? Quickshell.iconPath("audio-volume-muted") : Quickshell.iconPath("audio-volume-high")
            PwObjectTracker {
                objects: [audio_row.audio_sink]
            }
            area.onPressed: mouse => {
                if (mouse.button == Qt.LeftButton)
                    audio_row.audio_sink.audio.muted = !audio_row.audio_sink.audio.muted;
                else if (mouse.button == Qt.RightButton) {
                    speaker_menu.visible = !speaker_menu.visible;
                }
            }
        }

        ClickableIcon {
            id: mic_item
            source: audio_row.audio_source.audio.muted ? Quickshell.iconPath("mic-off") : Quickshell.iconPath("mic-ready")
            PwObjectTracker {
                objects: [audio_row.audio_source]
            }
            area.onPressed: mouse => {
                if (mouse.button == Qt.LeftButton)
                    audio_row.audio_source.audio.muted = !audio_row.audio_source.audio.muted;
            }
        }

        PopupWindow {
            id: speaker_menu
            anchor {
                item: speaker_item
                edges: Edges.Bottom | Edges.Right
                gravity: Edges.Bottom | Edges.Left
            }
            implicitWidth: speaker_column.implicitWidth + 20
            implicitHeight: speaker_column.implicitHeight + 20
            color: "transparent"
            Rectangle {
                radius: 10
                color: Style.fg
                anchors.fill: parent
                Rectangle {
                    radius: 10
                    color: Style.bg
                    anchors.centerIn: parent
                    implicitWidth: parent.width - 2
                    implicitHeight: parent.height - 2
                }
            }

            ColumnLayout {
                id: speaker_column
                spacing: 5
                anchors.centerIn: parent
                Repeater {
                    model: audio_row.audio_nodes.filter(node => node.isSink && node.name && !node.isStream)

                    Rectangle {
                        id: speaker_rect
                        required property var modelData
                        radius: 5
                        color: "#00FFFFFF"
                        Layout.minimumWidth: 300
                        Layout.minimumHeight: children[0].height + 10

                        Text {
                            anchors {
                                left: speaker_rect.left
                                leftMargin: 10
                                verticalCenter: speaker_rect.verticalCenter
                            }
                            PwObjectTracker {
                                objects: [speaker_rect.modelData]
                            }
                            color: Style.fg
                            text: speaker_rect.modelData.nickname
                        }

                        IconImage {
                            anchors {
                                right: speaker_rect.right
                                rightMargin: 10
                                verticalCenter: speaker_rect.verticalCenter
                            }
                            implicitSize: Style.icon_size
                            mipmap: true
                            source: Quickshell.iconPath("checkmark")
                            visible: speaker_rect.modelData == audio_row.audio_sink
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true
                            onPressed: mouse => {
                                if (mouse.button == Qt.LeftButton) {
                                    Pipewire.preferredDefaultAudioSink = speaker_rect.modelData;
                                    speaker_menu.visible = !speaker_menu.visible;
                                }
                            }
                            onEntered: () => {
                                speaker_rect.color = "#11FFFFFF";
                            }
                            onExited: () => {
                                speaker_rect.color = "#00FFFFFF";
                            }
                        }
                    }
                }
            }
        }
    }

    component ClickableIcon: IconImage {
        implicitSize: Style.icon_size
        mipmap: true
        property alias area: click_area
        Rectangle {
            id: icon_rect
            radius: 5
            color: "#00FFFFFF"
            width: Style.icon_size + 10
            height: Style.icon_size + 10
            anchors.centerIn: parent
        }

        MouseArea {
            id: click_area
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true
            onEntered: () => {
                icon_rect.color = "#11FFFFFF";
            }
            onExited: () => {
                icon_rect.color = "#00FFFFFF";
            }
        }
    }

    component BatteryModule: Row {
        readonly property list<UPowerDevice> batDevices: UPower.devices.values
        Text {
            text: parent.batDevices.find(x => x.isLaptopBattery).percentage
        }
    }
}
