import style from "./style.scss";
import Bar from "./widget/Bar";
import app from "ags/gtk3/app";
import { Astal, Gtk } from "ags/gtk3";
import Gdk from "gi://Gdk?version=3.0";

app.start({
  css: style,
  main() {
    const wl_display = Gdk.Display.get_default();
    if (!wl_display) return;

    const main_monitor =
      app.get_monitors().find((x) => x.get_workarea().x === 1440) ??
      app.get_monitors()[0];
    const monitorCount = app.get_monitors().length;
    Bar(main_monitor) as Astal.Window;

    wl_display.connect("monitor-removed", (_, monitor) => {
      if (monitor.get_workarea().x === 1440 || monitorCount === 1) {
        app.quit();
      }
    });
  },

  requestHandler(_, response) {
    response("Quitting...");
    app.quit();
  },
});
