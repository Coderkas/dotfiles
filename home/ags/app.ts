import { App, Gdk, Gtk } from "astal/gtk3";
import style from "./style.scss";
import Bar from "./widget/Bar";
import { timeout } from "astal";

App.start({
    css: style,
    main() {
        const main_monitor = App.get_monitors().find(x => x.get_workarea().x === 1440) ?? App.get_monitors()[0];
        const monitorCount = App.get_monitors().length;
        let appWidget = Bar(main_monitor);

        App.connect("monitor-added", (_, monitor) => {
            timeout(500, () => {
                print("Added event");
                if (monitor.get_workarea().x === 1440) {
                    print("Added");
                    appWidget = Bar(monitor);
                }
                else if (monitorCount === 1) {
                    print("Added alt");
                    appWidget = Bar(monitor);
                }
            })
        })

        App.connect("monitor-removed", (_, _m) => {
            appWidget.destroy();
        })
    },
});
