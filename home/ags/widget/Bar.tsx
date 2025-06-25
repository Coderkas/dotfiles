import { App, Astal, Gtk, Gdk, astalify, ConstructProps } from "astal/gtk3"
import { Binding, GLib, GObject, Variable, bind, interval, timeout } from "astal"
import Battery from "gi://AstalBattery"
import Hyprland from "gi://AstalHyprland"
import Tray from "gi://AstalTray"
import Wp from "gi://AstalWp"

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
    const wp_audio = Wp.get_default()?.audio
    const hypr_instance = Hyprland.get_default()

    const rs_window: RSWindow = {
        windowInstance: new Astal.Window(), type: RSWindowType.None, stateChange: (nextState: RSWindowType) => {
            switch (rs_window.type) {
                case RSWindowType.None:
                    if (nextState == RSWindowType.AudioWin) {
                        rs_window.type = nextState
                        CreateRSWindow(SpeakersList(wp_audio!, rs_window), rs_window)
                    }
                    else if (nextState == RSWindowType.CalendarWin) {
                        rs_window.type = nextState
                        CreateRSWindow(Calendar(), rs_window)
                    }
                    break;
                case RSWindowType.AudioWin:
                    if (nextState == RSWindowType.AudioWin) {
                        rs_window.type = RSWindowType.None
                        rs_window.windowInstance.destroy()
                    }
                    else if (nextState == RSWindowType.CalendarWin) {
                        rs_window.type = RSWindowType.CalendarWin
                        rs_window.windowInstance.destroy()
                        CreateRSWindow(Calendar(), rs_window)
                    }
                    break;
                case RSWindowType.CalendarWin:
                    if (nextState == RSWindowType.CalendarWin) {
                        rs_window.type = RSWindowType.None
                        rs_window.windowInstance.destroy()
                    }
                    else if (nextState == RSWindowType.AudioWin) {
                        rs_window.type = RSWindowType.AudioWin
                        rs_window.windowInstance.destroy()
                        CreateRSWindow(SpeakersList(wp_audio!, rs_window), rs_window)
                    }
                    break;
            }
        }
    }

    const audio_button = wp_audio ? AudioButton(rs_window) : <icon
        tooltipText={"Speakers or Wireplumber are missing"}
        icon={"audio-volume-muted"}
    />

    return <window
        className="Bar"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}
        application={App}>
        <centerbox>
            <box
                hexpand
                className="BarPart"
            >
                <BatteryStatus />
                <Reminders />
                <WorkspaceStatus hyprInstance={hypr_instance} />
            </box>
            <box
                hexpand
                halign={Gtk.Align.CENTER}
                className="BarPart"
            >
                <FocusedClientStatus hyprInstance={hypr_instance} />
            </box>
            <box
                hexpand
                halign={Gtk.Align.END}
                className="BarPart"
            >
                <SysTrayStatus />
                {audio_button}
                {TimeStatus(rs_window)}
            </box>
        </centerbox>
    </window>
}

function BatteryStatus() {
    const bat = Battery.get_default()

    return <box visible={bind(bat, "isPresent")}>
        <label label={bind(bat, "percentage").as((p) =>
            `${Math.floor(p * 100)} %`)}
        />
        <icon icon={bind(bat, "batteryIconName")} />
    </box>
}

function Reminders() {
    let drop_visible = Variable(false);
    let stand_visible = Variable(false);
    let move_visible = Variable(false);
    const minute = 60000

    const hydration = interval(10 * minute, () => {
        drop_visible.set(true)
        timeout(minute, () => drop_visible.set(false))
    })
    const standup = interval(60 * minute, () => {
        let animate_var = true;
        let animate_time = interval(1000, () => {
            stand_visible.set(animate_var)
            move_visible.set(!animate_var)
            animate_var = !animate_var
        })
        timeout(5 * minute, () => {
            stand_visible.set(false)
            move_visible.set(false)
            animate_time.cancel()
        })
    })

    return <box
        className="Reminders"
        halign={Gtk.Align.CENTER}
        onDestroy={() => {
            hydration.cancel()
            standup.cancel()
            drop_visible.drop()
            stand_visible.drop()
            move_visible.drop()
        }}
    >
        <icon visible={bind(drop_visible)} icon={"colors-chromablue"} />
        <label visible={bind(stand_visible)} label={"\udb81\udd83"} />
        <label visible={bind(move_visible)} label={"\udb81\udf0e"} />
    </box>
}

function WorkspaceStatus({ hyprInstance }: HyprlandWidgetsParams) {
    const kanji = ["一", "二", "三", "四", "五", "六", "七", "八", "九"];
    const spaces = bind(hyprInstance, "workspaces")

    return <box
        className="WorkspaceStatus"
        halign={Gtk.Align.END}
    >
        {
            spaces.as(ws => ws.reverse().map((w, wi) =>
                <box className="WorkspaceItem">
                    <label label={kanji[wi]} />
                    {bind(w, "clients").as(cs => cs.map(c => <icon icon={c.class} />))}
                </box>
            ))
        }
    </box>
}

function FocusedClientStatus({ hyprInstance }: HyprlandWidgetsParams) {
    return <box>
        {bind(hyprInstance, "focusedClient").as(c => (
            <label
                truncate
                className="FocusedClient"
                label={c ? bind(c, "title").as(t => t ? t : "") : ""} />
        ))}
    </box>
}

function SysTrayStatus() {
    const tray = Tray.get_default()

    return <box className="SysTrayStatus">
        {bind(tray, "items").as(items => items.map(item => (
            <button
                className="SysTrayItem"
                tooltipMarkup={bind(item, "tooltipMarkup")}
                onClick={(self, event) => {
                    if (event.button == Gdk.BUTTON_PRIMARY) item.activate(0, 0);
                    if (event.button == Gdk.BUTTON_SECONDARY) {
                        const mmodel = bind(item, "menuModel");
                        const menu = Gtk.Menu.new_from_model(mmodel.get())
                        const agroup = bind(item, "actionGroup").get()
                        menu.insert_action_group('dbusmenu', agroup)
                        menu.popup_at_widget(self, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, null)
                    }
                }}
            >
                <icon gicon={bind(item, "gicon")} visible={true} />
            </button>
        )))}
    </box>
}

function AudioButton(rs_window: RSWindow) {
    return <button
        className="AudioButton"
        onClick={() => {
            rs_window.stateChange(RSWindowType.AudioWin)
        }}>
        <icon icon={"audio-speaker-right-side"} />
    </button>
}

function SpeakersList(wp_audio: Wp.Audio, rs_window: RSWindow) {
    const wp_speakers = bind(wp_audio, "speakers")

    return wp_speakers.as(speakers =>
        speakers.map(s =>
            <centerbox>
                <button
                    halign={Gtk.Align.START}
                    hexpand={false}
                    label={s.description}
                    onClick={() => {
                        s.set_is_default(true)
                        rs_window.stateChange(RSWindowType.AudioWin)
                    }}
                />
                <box hexpand={true} />
                <icon halign={Gtk.Align.END} hexpand={false} visible={s.is_default} icon={"dialog-ok-apply"} />
            </centerbox>
        )
    )
}

function TimeStatus(rs_window: RSWindow) {
    const time = Variable<string>("").poll(1000, () => GLib.DateTime.new_now_local().format("%H:%M | %d.%m.%Y")!)

    return <button
        className="TimeItem"
        onDestroy={() => time.drop()}
        label={time()}
        onClick={() => rs_window.stateChange(RSWindowType.CalendarWin)}
    />
}

function Calendar() {
    return <MyCalendar
        className="Calendar"
        showDetails={false}
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}
        expand
        showDayNames
        showHeading
    />
}

type HyprlandWidgetsParams = {
    hyprInstance: Hyprland.Hyprland
}

type RSWindow = {
    windowInstance: Astal.Window
    type: RSWindowType
    stateChange: (nextState: RSWindowType) => void
}

enum RSWindowType {
    CalendarWin,
    AudioWin,
    None
}

function CreateRSWindow(child_wg: Gtk.Widget | Gtk.Widget[] | Binding<Gtk.Widget> | Binding<Gtk.Widget[]>, rs_window: RSWindow) {
    return <window
        className="RSWindow"
        setup={self => rs_window.windowInstance = self}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
    >
        <box
            className="RSWindowBox"
            vertical={true}
            valign={Gtk.Align.FILL}
        >
            {child_wg}
        </box>
    </window>
}

class MyCalendar extends astalify(Gtk.Calendar) {
    static {
        GObject.registerClass(this)
    }

    constructor(props: ConstructProps<MyCalendar, Gtk.Calendar.ConstructorProps>) {
        super(props as any);
    }
}
