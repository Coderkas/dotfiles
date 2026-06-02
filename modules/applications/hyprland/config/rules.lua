hl.window_rule { match = { class = ".*" }, suppress_event = "maximize" }
hl.window_rule { match = { class = "[wW]aydroid.*" }, float = true, size = "{1024, 576}" }
hl.window_rule { match = { class = "^(org.gnome.clocks)$" }, float = true, size = "{800, 520}" }
hl.window_rule { match = { class = "^(zenity)$" }, float = true }
hl.window_rule { match = { initial_class = "^(steam)$", initial_title = "negative:^(Steam|)$" }, float = true }
hl.layer_rule { match = { namespace = "^(anyrun)$" }, no_anim = true, dim_around = true }

-- Bunch of rules yoinked from
-- https://github.com/CachyOS/cachyos-hyprland-settings/blob/master/etc/skel/.config/hypr/config/windowrules.conf
hl.window_rule { match = { title = "^([Pp]icture[ -]in[ -][Pp]icture)$" }, float = true }
hl.window_rule { match = { title = "^(Save File)$" }, float = true }
hl.window_rule { match = { title = "^(Open File)$" }, float = true }
hl.window_rule { match = { title = "^(Steam - Self Updater)$" }, float = true }

local portal_rgx = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)$"
hl.window_rule { match = { class = portal_rgx }, float = true }

local auth_rgx = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)$"
hl.window_rule { match = { class = auth_rgx }, float = true }

-- Smart gaps from https://wiki.hypr.land/Configuring/Workspace-Rules/#smart-gaps
hl.workspace_rule { workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 }
hl.workspace_rule { workspace = "f[1]", gaps_in = 0, gaps_out = 0 }
hl.window_rule { match = { float = false, workspace = "w[tv1]", focus = false }, border_color = "rgba(595959ff)" }
hl.window_rule { match = { float = false, workspace = "f[1]", focus = false }, border_color = "rgba(595959ff)" }

-- game rules
hl.window_rule {
    name = "gayming",
    match = {
        class = "^(hunt.exe|Overwatch.exe|nightreign.exe|chaosgate.exe|Warhammer 40000 Space Marine 2.exe|ReadyOrNot.exe|warhammer3.exe)$",
    },
    float = false,
    fullscreen = true,
    idle_inhibit = "fullscreen",
    content = "game",
    immediate = true,
    render_unfocused = true,
    suppress_event = "fullscreen fullscreenoutput",
}

hl.window_rule {
    name = "nte",
    match = {
        class = "^(steam_app_default)$",
        title = "^(NTE)$",
    },
    idle_inhibit = "fullscreen",
    content = "game",
    immediate = true,
    render_unfocused = true,
}

hl.window_rule {
    name = "minecraft",
    match = { initial_title = "^(Minecraft.*)$" },
    float = false,
    idle_inhibit = "fullscreen",
    content = "game",
    immediate = true,
    render_unfocused = true,
    fullscreen_state = "2 2",
    suppress_event = "fullscreen fullscreenoutput",
}
