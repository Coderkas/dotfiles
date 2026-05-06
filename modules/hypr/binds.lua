local mainMod = "SUPER"
local vars = require "vars"

hl.bind(mainMod .. " + C",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.kill())
hl.bind(mainMod .. " + M",         hl.dsp.exit())
hl.bind(mainMod .. " + V",         hl.dsp.window.float { action = "toggle" })
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen { mode = "maximized" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen { mode = "fullscreen" })
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd "hyprpicker -a")

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh select")
hl.bind(mainMod .. " + S",         hl.dsp.submap "screenshot")

hl.define_submap("screenshot", "reset", function ()
	hl.bind("W",        hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh window")
	hl.bind("M",        hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh monitor")
	hl.bind("catchall", hl.dsp.submap "reset")
end)

-- application bindings for terminal, app launcher/menu and browser
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(vars.cmenu))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(vars.browser))

-- screenreading with tesseract
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.submap "tesseract")

hl.define_submap("tesseract", "reset", function ()
	hl.bind("J",        hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh tesseract jpn")
	hl.bind("V",        hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh tesseract jpn_vert")
	hl.bind("E",        hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh tesseract eng")
	hl.bind("D",        hl.dsp.exec_cmd "~/.config/hypr/screenshot.sh tesseract ger")
	hl.bind("catchall", hl.dsp.submap "reset")
end)

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus { direction = "left" })
hl.bind(mainMod .. " + L", hl.dsp.focus { direction = "right" })
hl.bind(mainMod .. " + K", hl.dsp.focus { direction = "up" })
hl.bind(mainMod .. " + J", hl.dsp.focus { direction = "down" })

-- Move active window in direction with mainMod + hjkl
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move { direction = "left" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move { direction = "right" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move { direction = "up" })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move { direction = "down" })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key,         hl.dsp.focus { workspace = i })
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move { workspace = i })
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + ALT + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus { workspace = "e+1" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus { workspace = "e-1" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%+", { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%-", { locked = true, repeating = true })
