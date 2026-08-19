-- Omarchy-like Hyprland 0.55+ profile using local/generic tools only.

local common = require("profiles.common")
local mod = "SUPER"
local home = os.getenv("HOME") or "/home/marcelof"

local function bin(name)
  return home .. "/bin/" .. name
end

local terminal = bin("hypr-term")
local launcher = bin("qbar") .. " launcher"
local root_menu = bin("qbar") .. " shell toggle omarchy.menu '{}'"
local quickshell_cmd = common.quickshell_cmd(home)
local board_run_cmd = common.board_run_cmd(home)

local function sh(cmd)
  return hl.dsp.exec_cmd(cmd)
end

local function qs(action)
  return sh(bin("qbar") .. " " .. action)
end

local function osd(action)
  return sh(bin("desktop-osd") .. " " .. action)
end

local function audio(action)
  return sh(bin("audioctl") .. " " .. action)
end

local function screenshot(action)
  return sh(bin("screenshot-wayland") .. " " .. action)
end

local function bind_app(keys, cmd)
  hl.bind(keys, sh(cmd))
end

local function note(message)
  return sh("notify-send 'Hyprland omarchy profile' " .. string.format("%q", message))
end


hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

common.apply_default_monitors()

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "compose:caps",
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    follow_mouse = 1,
    touchpad = {
      clickfinger_behavior = true,
      scroll_factor = 0.4,
      natural_scroll = false,
    },
  },

  general = {
    gaps_in = 8,
    gaps_out = 16,
    border_size = 1,
    layout = "dwindle",
    ["col.active_border"] = common.colors.border_active,
    ["col.inactive_border"] = common.colors.border_inactive,
  },
  group = common.group_config(),

  decoration = {
    rounding = 8,
    dim_inactive = true,
    dim_strength = 0.15,
    blur = {
      enabled = true,
      size = 4,
      passes = 2,
    },
  },

  animations = { enabled = true },

  dwindle = {
    preserve_split = true,
    smart_resizing = true,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },
})

hl.workspace_rule({ workspace = "3", monitor = "DP-2" })

common.apply_common_popup_rules()
hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = common.classes.ghostty }, scroll_touchpad = 0.2 })
common.apply_dropdown_rules()

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XAUTHORITY")
  hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XAUTHORITY")
  hl.exec_cmd("systemctl --user restart espanso.service")
  hl.exec_cmd("systemctl --user stop dunst.service")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark")
  hl.exec_cmd(quickshell_cmd)
  hl.exec_cmd(board_run_cmd)
  hl.exec_cmd("dex --autostart --environment Hyprland")
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
  hl.exec_cmd("command -v chrome-wayland-fix-apps >/dev/null 2>&1 && chrome-wayland-fix-apps")
  hl.exec_cmd("command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1 && cliphist-menu watch")
end)

-- open terminal
hl.bind(mod .. " + RETURN", sh(terminal))
hl.bind(mod .. " + U", sh(terminal .. " popup-tmux"))
-- open tmux launcher
hl.bind(mod .. " + ALT + RETURN", sh("tmx"))
hl.bind(mod .. " + SHIFT + RETURN", sh("xdg-open about:blank"))
-- open root menu
hl.bind(mod .. " + SPACE", sh(root_menu))
hl.bind(mod .. " + D", sh(launcher))
hl.bind(mod .. " + C", common.universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))
hl.bind(mod .. " + V", common.universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert"))
hl.bind(mod .. " + X", common.send_shortcut_once("CTRL", "X"))
-- open clipboard history
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + C", sh(common.actions.hypr_reload))
hl.bind(mod .. " + SHIFT + R", sh(common.actions.hypr_reload))
hl.bind(mod .. " + ESCAPE", qs("power"))
hl.bind(mod .. " + ALT + SPACE", qs("power"))
hl.bind("XF86PowerOff", qs("power"), { locked = true })
hl.bind("XF86Calculator", sh("gnome-calculator"))
hl.bind(mod .. " + SHIFT + E", qs("power"))
hl.bind(mod .. " + SLASH", qs(common.actions.keybindings))
hl.bind(mod .. " + K", qs(common.actions.keybindings))
hl.bind(mod .. " + ALT + K", sh(terminal .. " tmux list-keys"))
hl.bind(mod .. " + SHIFT + SPACE", qs("toggle"))

common.bind_direction_keys(mod, common.arrow_directions, hl.dsp.focus)
common.bind_direction_keys(mod .. " + SHIFT", common.arrow_directions, hl.dsp.window.swap)

hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + CTRL + F", sh("hyprctl dispatch fullscreenstate 0 2"))
hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + O", sh("hyprctl dispatch togglefloating; hyprctl dispatch pin"))
hl.bind(mod .. " + L", qs("lock"), { locked = true })

hl.bind(mod .. " + S", sh("hypr-scratch toggle"))
hl.bind(mod .. " + ALT + S", sh("hypr-scratch move"))
hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + TAB", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + SHIFT + PERIOD", hl.dsp.workspace.move({ monitor = "+1" }))

common.bind_workspace_numbers(mod, {
  focus = function(workspace) return hl.dsp.focus({ workspace = workspace }) end,
  move = function(workspace) return hl.dsp.window.move({ workspace = workspace }) end,
  move_no_follow = function(workspace) return hl.dsp.window.move({ workspace = workspace, follow = false }) end,
})

hl.bind(mod .. " + SHIFT + ALT + LEFT", hl.dsp.workspace.move({ monitor = "left" }))
hl.bind(mod .. " + SHIFT + ALT + RIGHT", hl.dsp.workspace.move({ monitor = "right" }))
hl.bind(mod .. " + SHIFT + ALT + UP", hl.dsp.workspace.move({ monitor = "up" }))
hl.bind(mod .. " + SHIFT + ALT + DOWN", hl.dsp.workspace.move({ monitor = "down" }))

hl.bind("ALT + TAB", sh("hyprctl dispatch cyclenext; hyprctl dispatch bringactivetotop"))
hl.bind("ALT + SHIFT + TAB", sh("hyprctl dispatch cyclenext prev; hyprctl dispatch bringactivetotop"))
hl.bind("CTRL + ALT + TAB", hl.dsp.focus({ monitor = "+1" }))
hl.bind("CTRL + ALT + SHIFT + TAB", hl.dsp.focus({ monitor = "-1" }))

hl.bind(mod .. " + CTRL + code:20", sh("hyprctl dispatch resizeactive -100 0"))
hl.bind(mod .. " + CTRL + code:21", sh("hyprctl dispatch resizeactive 100 0"))
hl.bind(mod .. " + CTRL + SHIFT + code:20", sh("hyprctl dispatch resizeactive 0 -100"))
hl.bind(mod .. " + CTRL + SHIFT + code:21", sh("hyprctl dispatch resizeactive 0 100"))
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mod .. " + ALT + LEFT", hl.dsp.window.move({ into_group = "l" }))
hl.bind(mod .. " + ALT + RIGHT", hl.dsp.window.move({ into_group = "r" }))
hl.bind(mod .. " + ALT + UP", hl.dsp.window.move({ into_group = "u" }))
hl.bind(mod .. " + ALT + DOWN", hl.dsp.window.move({ into_group = "d" }))
hl.bind(mod .. " + ALT + TAB", hl.dsp.group.next())
hl.bind(mod .. " + ALT + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mod .. " + CTRL + LEFT", hl.dsp.group.prev())
hl.bind(mod .. " + CTRL + RIGHT", hl.dsp.group.next())
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- open file manager
bind_app(mod .. " + SHIFT + F", "nautilus")
bind_app(mod .. " + SHIFT + B", "xdg-open about:blank")
-- open Neovim
bind_app(mod .. " + SHIFT + N", "nvim")
bind_app(mod .. " + SHIFT + D", terminal .. " lazydocker")
bind_app(mod .. " + SHIFT + O", "obsidian")
bind_app(mod .. " + SHIFT + W", "typora --enable-wayland-ime")
hl.bind("XF86Display", sh("monitor"), { locked = true, repeating = true })
hl.bind(mod .. " + CTRL + A", qs("controls"))
hl.bind(mod .. " + CTRL + B", qs("controls"))
hl.bind(mod .. " + CTRL + E", qs("emojis"))
hl.bind(mod .. " + CTRL + C", qs("screen"))
hl.bind(mod .. " + CTRL + D", sh("monitor"))
hl.bind(mod .. " + CTRL + SPACE", qs("wallpaper"))
hl.bind(mod .. " + CTRL + SHIFT + SPACE", qs("settings"))
hl.bind(mod .. " + SHIFT + ALT + comma", qs("notifications"))
hl.bind(mod .. " + CTRL + comma", qs("dnd"))
hl.bind(mod .. " + CTRL + ALT + T", sh(bin("qbar") .. " notice time"))
hl.bind(mod .. " + CTRL + ALT + B", sh(bin("qbar") .. " notice battery"))
hl.bind(mod .. " + CTRL + ALT + W", sh(bin("qbar") .. " notice weather"))
hl.bind(mod .. " + CTRL + V", function() end)
hl.bind(mod .. " + CTRL + W", function() end)
hl.bind(mod .. " + CTRL + P", qs("power"))
hl.bind(mod .. " + CTRL + L", qs("lock"), { locked = true })
bind_app(mod .. " + I", terminal .. " htop")

hl.bind("XF86AudioRaiseVolume", osd("volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", osd("volume-down"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioRaiseVolume", osd("volume-fine-up"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioLowerVolume", osd("volume-fine-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", osd("mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", osd("mic-mute"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", sh("playerctl next"), { locked = true })
hl.bind(mod .. " + M", audio(common.actions.play_pause_all), { locked = true })
hl.bind("XF86AudioPause", audio(common.actions.play_pause_all), { locked = true })
hl.bind("XF86AudioPlay", audio(common.actions.play_pause_all), { locked = true })
hl.bind("XF86AudioPrev", sh("playerctl previous"), { locked = true })
hl.bind("XF86KbdBrightnessUp", osd("kbd-up"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", osd("kbd-down"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", osd("brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", osd("brightness-down"), { locked = true, repeating = true })
hl.bind("ALT + XF86MonBrightnessUp", osd("brightness-fine-up"), { locked = true, repeating = true })
hl.bind("ALT + XF86MonBrightnessDown", osd("brightness-fine-down"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86MonBrightnessUp", osd("brightness-max"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86MonBrightnessDown", osd("brightness-min"), { locked = true, repeating = true })
hl.bind("PRINT", screenshot("edit"))
hl.bind(mod .. " + PRINT", sh("command -v hyprpicker >/dev/null 2>&1 && hyprpicker -a || notify-send 'Hyprland omarchy profile' 'hyprpicker is not installed'"))
