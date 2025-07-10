import style from "./style.scss";
import Bar from "./widget/Bar";
import { timeout } from "ags/time";
import App from "ags/gtk3/app";
import { Astal } from "ags/gtk3";

App.start({
  css: style,
  main() {
    const main_monitor =
      App.get_monitors().find((x) => x.get_workarea().x === 1440) ??
      App.get_monitors()[0];
    const monitorCount = App.get_monitors().length;
    let appWidget = Bar(main_monitor) as Astal.Window;

    App.connect("monitor-added", (_, monitor) => {
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

    App.connect("monitor-removed", (_, _m) => {
      appWidget.destroy();
    });
  },
});
