local vars = require "vars"

hl.config {
	general    = {
		gaps_in          = 5,
		gaps_out         = 5,
		border_size      = 3,
		resize_on_border = false,
		col              = {
			active_border   = "rgb(d4be98)",
			inactive_border = "rgba(595959aa)",
		},
		allow_tearing    = true, -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
		layout           = "dwindle",
		snap             = { enabled = true },
	},

	decoration = {
		rounding         = 10,
		active_opacity   = 1.0,
		inactive_opacity = 1.0,

		shadow           = {
			enabled      = true,
			range        = 4,
			render_power = 3,
			color        = "rgba(1a1a1aee)",
		},

		blur             = {
			enabled  = true,
			size     = 3,
			passes   = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	input      = {
		kb_options   = "ctrl:nocaps",
		follow_mouse = 1,
		repeat_delay = 180,
		sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.
	},

	dwindle    = {
		preserve_split = true,
	},

	misc       = {
		vrr                      = 3,
		disable_hyprland_logo    = true,
		disable_splash_rendering = true,
		force_default_wallpaper  = 0,
		anr_missed_pings         = 15,
		enable_swallow           = true,
		swallow_regex            = "^(kitty|com.mitchellh.ghostty|yazi)$",
		disable_watchdog_warning = true,
	},

	binds      = {
		movefocus_cycles_fullscreen = true,
	},

	render     = {
		direct_scanout = 1,
		cm_auto_hdr    = 2,
	},

	cursor     = {
		default_monitor   = vars.mainMonitor,
		hide_on_key_press = true,
	},

	debug      = {
		disable_logs = true,
	},
}

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation { leaf = "windows", enabled = true, speed = 6, bezier = "myBezier" }
hl.animation { leaf = "windowsOut", enabled = true, speed = 2, bezier = "default", style = "slide" }
hl.animation { leaf = "windowsIn", enabled = true, speed = 2, bezier = "default", style = "slide" }
hl.animation { leaf = "border", enabled = true, speed = 10, bezier = "default" }
hl.animation { leaf = "borderangle", enabled = true, speed = 8, bezier = "default" }
hl.animation { leaf = "fade", enabled = true, speed = 7, bezier = "default" }
hl.animation { leaf = "workspaces", enabled = true, speed = 6, bezier = "default" }
