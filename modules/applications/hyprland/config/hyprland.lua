local vars = require "vars"

if vars.host == "omnissiah" then
    hl.monitor { output = "DP-1", mode = "2560x1440@60", position = "0x0", scale = "1", transform = 1 }

    hl.monitor { output = "DP-2", mode = "2560x1440@165", position = "1440x700", scale = "1", transform = 0 }

    hl.monitor { output = "DP-3", mode = "2560x1440@60", position = "4000x700", scale = "1", transform = 0 }

    hl.workspace_rule { workspace = "1", monitor = "DP-1", default = true }
    hl.workspace_rule { workspace = "2", monitor = "DP-2", default = true }
    hl.workspace_rule { workspace = "3", monitor = "DP-3", default = true }

    hl.on("hyprland.start", function()
        hl.exec_cmd("obsidian obsidian://open?file=Timeplaning.md", { workspace = "2 silent" })
        hl.exec_cmd("xrandr --output " .. vars.primaryMonitor .. " --primary")
    end)
elseif vars.host == "servitor" then
    hl.monitor { output = "eDP-1", mode = "2560x1600@165", position = "0x0", scale = "1", transform = 0 }

    hl.workspace_rule { workspace = "1", monitor = "eDP-1", default = true }
elseif vars.host == "medusa" then
    hl.monitor { output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = "1", transform = 0 }

    hl.exec_cmd("hyprctl plugin load /run/current-system/sw/lib/libhyprgrass.so")
    -- TODO: finish setting up plugin stuff
    -- Relevant snippet from former medusa.conf:
    -- plugin {
    -- touch_gestures {
    -- hyprgrass-bind = , edge:d:u, exec, $browser
    -- hyprgrass-bind = , edge:d:l, exec, $fileManager
    -- hyprgrass-bind = , edge:d:r, exec, $terminal
    -- hyprgrass-bind = , edge:u:d, killactive
    -- hyprgrass-bind = , longpress:3, fullscreen
    -- hyprgrass-bind = , edge:l:u, exec, $toggleWvkbd
    -- }
    -- }
    -- hl.plugin({ touch_gestures = {} })
end

require "settings"
require "binds"
require "rules"
-- require "logger"
