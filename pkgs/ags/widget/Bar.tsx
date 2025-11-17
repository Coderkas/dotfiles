import App from "ags/gtk3/app";
import { Astal } from "ags/gtk3";
import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk";
import GLib from "gi://GLib";
import { Accessor, createBinding, createState, For, With } from "ags";
import { timeout, interval, createPoll, Timer } from "ags/time";
import Battery from "gi://AstalBattery";
import Hyprland from "gi://AstalHyprland";
import Tray from "gi://AstalTray";
import Wp from "gi://AstalWp";

export default function Bar(gdkmonitor: Gdk.Monitor): Astal.Window {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;
  const wp_audio = Wp.get_default()?.audio;
  const hypr_instance = Hyprland.get_default();

  const rs_window: RSWindow = {
    windowInstance: new Astal.Window(),
    type: RSWindowType.None,
    stateChange: (nextState: RSWindowType) => {
      switch (rs_window.type) {
        case RSWindowType.None:
          if (nextState == RSWindowType.AudioWin) {
            rs_window.type = nextState;
            CreateRSWindow(SpeakersList(wp_audio!, rs_window), rs_window);
          } else if (nextState == RSWindowType.CalendarWin) {
            rs_window.type = nextState;
            CreateRSWindow(Calendar(), rs_window);
          }
          break;
        case RSWindowType.AudioWin:
          if (nextState == RSWindowType.AudioWin) {
            rs_window.type = RSWindowType.None;
          } else if (nextState == RSWindowType.CalendarWin) {
            rs_window.type = RSWindowType.CalendarWin;
            CreateRSWindow(Calendar(), rs_window);
          }
          break;
        case RSWindowType.CalendarWin:
          if (nextState == RSWindowType.CalendarWin) {
            rs_window.type = RSWindowType.None;
          } else if (nextState == RSWindowType.AudioWin) {
            rs_window.type = RSWindowType.AudioWin;
            CreateRSWindow(SpeakersList(wp_audio!, rs_window), rs_window);
          }
          break;
      }
    },
  };

  const audio_button = wp_audio ? (
    AudioButton(rs_window)
  ) : (
    <icon
      tooltipText={"Speakers or Wireplumber are missing"}
      icon={"audio-volume-muted"}
    />
  );

  return (
    <window
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox>
        <box hexpand class="BarPart">
          <BatteryStatus />
          <Reminders />
          <WorkspaceStatus hyprInstance={hypr_instance} />
        </box>
        <box hexpand halign={Gtk.Align.CENTER} class="BarPart">
          <FocusedClientStatus hyprInstance={hypr_instance} />
        </box>
        <box hexpand halign={Gtk.Align.END} class="BarPart">
          <SysTrayStatus />
          {audio_button}
          {TimeStatus(rs_window)}
        </box>
      </centerbox>
    </window>
  ) as Astal.Window;
}

function BatteryStatus(): Astal.Box {
  const bat = Battery.get_default();

  return (
    <box visible={createBinding(bat, "isPresent")}>
      <label
        label={createBinding(bat, "percentage").as(
          (p) => `${Math.floor(p * 100)} %`,
        )}
      />
      <icon icon={createBinding(bat, "batteryIconName")} />
    </box>
  ) as Astal.Box;
}

function Reminders(): Astal.Box {
  let [showDrop, setShowDrop] = createState(false);
  let [showStand, setShowStand] = createState(false);
  let [showMove, setShowMove] = createState(false);
  const minute = 60000;

  let hydrate_timeout: Timer;
  const hydrate_timer = interval(10 * minute, () => {
    setShowDrop(true);
    hydrate_timeout = timeout(minute, () => setShowDrop(false));
  });

  let move_timeout: Timer;
  let animate = false;
  let showAnimation = false;
  const move_timer = interval(60 * minute, () => {
    showAnimation = true;
    move_timeout = timeout(5 * minute, () => (showAnimation = false));
  });
  const animation_timer = interval(1000, () => {
    setShowStand(showAnimation && !animate);
    setShowMove(showAnimation && animate);
  });

  return (
    <box
      class="Reminders"
      halign={Gtk.Align.CENTER}
      onDestroy={() => {
        hydrate_timer?.cancel();
        hydrate_timeout?.cancel();
        move_timer?.cancel();
        move_timeout?.cancel();
        animation_timer?.cancel();
      }}
    >
      <icon visible={showDrop} icon={"colors-chromablue"} />
      <label visible={showStand} label={"\udb81\udd83"} />
      <label visible={showMove} label={"\udb81\udf0e"} />
    </box>
  ) as Astal.Box;
}

function WorkspaceStatus({ hyprInstance }: HyprlandWidgetsParams): Astal.Box {
  const kanji = ["一", "二", "三", "四", "五", "六", "七", "八", "九"];
  const spaces = createBinding(hyprInstance, "workspaces").as((x) =>
    x.reverse(),
  );

  return (
    <box class="WorkspaceStatus" halign={Gtk.Align.END}>
      <For each={spaces}>
        {(w, wi) => (
          <box class="WorkspaceItem">
            <label label={wi((wi) => kanji[wi])} />
            <For each={createBinding(w, "clients")}>
              {(c: Hyprland.Client) => <icon icon={c.class} />}
            </For>
          </box>
        )}
      </For>
    </box>
  ) as Astal.Box;
}

function FocusedClientStatus({
  hyprInstance,
}: HyprlandWidgetsParams): Astal.Box {
  return (
    <box onDestroy={(_) => print("destroying focused client")}>
      <With value={createBinding(hyprInstance, "focusedClient")}>
        {(c: Hyprland.Client) => (
          <label
            truncate
            class="FocusedClient"
            label={c ? createBinding(c, "title").as((t) => (t ? t : "")) : ""}
          />
        )}
      </With>
    </box>
  ) as Astal.Box;
}

function SysTrayStatus(): Astal.Box {
  const tray = Tray.get_default();

  return (
    <box class="SysTrayStatus">
      <For each={createBinding(tray, "items")}>
        {(item: Tray.TrayItem) => (
          <button
            class="SysTrayItem"
            tooltipMarkup={createBinding(item, "tooltipMarkup")}
            onClick={(self, event) => {
              if (event.button == Gdk.BUTTON_PRIMARY) item.activate(0, 0);
              if (event.button == Gdk.BUTTON_SECONDARY) {
                const mmodel = createBinding(item, "menuModel");
                const menu = Gtk.Menu.new_from_model(mmodel.get());
                const agroup = createBinding(item, "actionGroup").get();
                menu.insert_action_group("dbusmenu", agroup);
                menu.popup_at_widget(
                  self,
                  Gdk.Gravity.NORTH,
                  Gdk.Gravity.SOUTH,
                  null,
                );
              }
            }}
          >
            <icon gicon={createBinding(item, "gicon")} visible={true} />
          </button>
        )}
      </For>
    </box>
  ) as Astal.Box;
}

function AudioButton(rs_window: RSWindow): Astal.Button {
  return (
    <button
      class="AudioButton"
      onClick={() => rs_window.stateChange(RSWindowType.AudioWin)}
    >
      <icon icon={"audio-speaker-right-side"} />
    </button>
  ) as Astal.Button;
}

function SpeakersList(
  wp_audio: Wp.Audio,
  rs_window: RSWindow,
): Astal.CenterBox[] | Astal.Label {
  const speakers = wp_audio.get_speakers();

  return (
    speakers ? (
      speakers.map((s) => (
        <centerbox>
          <button
            halign={Gtk.Align.START}
            hexpand={false}
            label={s.description}
            onClick={() => {
              s.set_is_default(true);
              rs_window.stateChange(RSWindowType.AudioWin);
            }}
          />
          <box hexpand={true} />
          <icon
            halign={Gtk.Align.END}
            hexpand={false}
            visible={s.is_default}
            icon={"dialog-ok-apply"}
          />
        </centerbox>
      ))
    ) : (
      <label label="No Speakers found" />
    )
  ) as Astal.CenterBox[] | Astal.Label;
}

function TimeStatus(rs_window: RSWindow): Astal.Button {
  const time = createPoll(
    "",
    1000,
    () => GLib.DateTime.new_now_local().format("%H:%M | %d.%m.%Y")!,
  );

  return (
    <button
      class="TimeItem"
      label={time}
      onClick={() => rs_window.stateChange(RSWindowType.CalendarWin)}
    />
  ) as Astal.Button;
}

function Calendar(): Gtk.Calendar {
  return (
    <Gtk.Calendar
      class="Calendar"
      showDetails={false}
      halign={Gtk.Align.FILL}
      valign={Gtk.Align.FILL}
      expand
      showDayNames
      showHeading
    />
  ) as Gtk.Calendar;
}

type HyprlandWidgetsParams = {
  hyprInstance: Hyprland.Hyprland;
};

type RSWindow = {
  windowInstance: Astal.Window;
  type: RSWindowType;
  stateChange: (nextState: RSWindowType) => void;
};

enum RSWindowType {
  CalendarWin,
  AudioWin,
  None,
}

function CreateRSWindow(
  child_widgets: Gtk.Widget[] | Gtk.Widget,
  rs_window: RSWindow,
): Astal.Window {
  return (
    <window
      class="RSWindow"
      $={(self) => (rs_window.windowInstance = self)}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
    >
      <box class="RSWindowBox" vertical={true} valign={Gtk.Align.FILL}>
        {child_widgets}
      </box>
    </window>
  ) as Astal.Window;
}
