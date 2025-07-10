import style from "./style.scss";
import Bar from "./widget/Bar";
import { timeout } from "ags/time";
import app from "ags/gtk3/app";
import { Astal } from "ags/gtk3";

app.start({
  css: style,
  main() {
    const main_monitor =
      app.get_monitors().find((x) => x.get_workarea().x === 1440) ??
      app.get_monitors()[0];
    const monitorCount = app.get_monitors().length;
    let appWidget = Bar(main_monitor) as Astal.Window;

    app.connect("monitor-added", (_, monitor) => {
      timeout(500, () => {
        print("Added event");
        if (monitor.get_workarea().x === 1440) {
          print("Added");
          appWidget = Bar(monitor) as Astal.Window;
        } else if (monitorCount === 1) {
          print("Added alt");
          appWidget = Bar(monitor) as Astal.Window;
        }
      });
    });

    app.connect("monitor-removed", (_, monitor) => {
      if (monitor.get_workarea().x === 1440 || monitorCount === 1) {
        appWidget.destroy();
        app.remove_window(appWidget);
      }
    });
  },
});
