-- Wayland-first Hyprland 0.55+ profile using local/generic tools only.

local mod = "SUPER"
local terminal = "hypr-term"
local launcher = "qs-launcher"

local function sh(cmd)
  return hl.dsp.exec_cmd(cmd)
end

local function bind_app(keys, cmd)
  hl.bind(keys, sh(cmd))
end

local function note(message)
  return sh("notify-send 'Hyprland modern profile' " .. string.format("%q", message))
end

local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

local terminal_classes = {
  alacritty = true,
  ["com.mitchellh.ghostty"] = true,
  foot = true,
  kitty = true,
  wezterm = true,
}

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window or not window.class then
    return false
  end

  return terminal_classes[window.class:lower()] == true
end

local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
  return function()
    if active_window_is_terminal() then
      send_shortcut_once(terminal_mods, terminal_key)()
    else
      send_shortcut_once(default_mods, default_key)()
    end
  end
end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto-right", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

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
    ["col.active_border"] = "rgba(b4befeff)",
    ["col.inactive_border"] = "rgba(313244ff)",
  },

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

hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, scroll_touchpad = 0.2 })
hl.window_rule({ match = { title = "dropdown_tmuxa" }, float = true, pin = true, size = { 625, 450 }, center = true })
hl.window_rule({ match = { class = "dropdown_tmuxa" }, workspace = "special:dropdown_tmuxa", float = true, pin = true, size = { 625, 450 }, center = true })

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XAUTHORITY")
  hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XAUTHORITY")
  hl.exec_cmd("systemctl --user restart espanso.service")
  hl.exec_cmd("systemctl --user stop dunst.service")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark")
  hl.exec_cmd("env QT_QUICK_BACKEND=software /home/marcelof/.nix-profile/bin/quickshell --path /home/marcelof/.config/quickshell/marcelof/shell.qml --no-duplicate --daemonize")
  hl.exec_cmd("dex --autostart --environment Hyprland")
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
  hl.exec_cmd("command -v chrome-wayland-fix-apps >/dev/null 2>&1 && chrome-wayland-fix-apps")
  hl.exec_cmd("command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1 && cliphist-menu watch")
end)

-- open terminal
hl.bind(mod .. " + RETURN", sh(terminal))
-- open tmux launcher
hl.bind(mod .. " + ALT + RETURN", sh("tmx"))
hl.bind(mod .. " + SHIFT + RETURN", sh("xdg-open about:blank"))
-- open app launcher
hl.bind(mod .. " + SPACE", sh(launcher))
hl.bind(mod .. " + D", sh(launcher))
hl.bind(mod .. " + C", universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))
hl.bind(mod .. " + V", universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert"))
hl.bind("mouse:274", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert", window = "activewindow" }))
hl.bind(mod .. " + X", send_shortcut_once("CTRL", "X"))
-- open clipboard history
hl.bind(mod .. " + CTRL + V", sh("cliphist-menu"))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + C", sh("hypr-session reload"))
hl.bind(mod .. " + SHIFT + R", sh("hypr-session reload"))
hl.bind(mod .. " + ESCAPE", sh("qs ipc call session confirmExit"))
hl.bind(mod .. " + SHIFT + E", sh("qs ipc call session confirmExit"))

hl.bind(mod .. " + LEFT", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + DOWN", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + UP", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + RIGHT", hl.dsp.focus({ direction = "right" }))

hl.bind(mod .. " + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }))

hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + CTRL + F", sh("hyprctl dispatch fullscreenstate 0 2"))
hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + O", sh("hyprctl dispatch togglefloating; hyprctl dispatch pin"))
hl.bind(mod .. " + L", sh("qs ipc call lock lock"), { locked = true })

hl.bind(mod .. " + S", sh("hypr-scratch toggle"))
hl.bind(mod .. " + ALT + S", sh("hypr-scratch move"))
hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + TAB", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + SHIFT + PERIOD", hl.dsp.workspace.move({ monitor = "+1" }))

for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
  hl.bind(mod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

hl.bind(mod .. " + SHIFT + ALT + LEFT", hl.dsp.workspace.move({ monitor = "left" }))
hl.bind(mod .. " + SHIFT + ALT + RIGHT", hl.dsp.workspace.move({ monitor = "right" }))
hl.bind(mod .. " + SHIFT + ALT + UP", hl.dsp.workspace.move({ monitor = "up" }))
hl.bind(mod .. " + SHIFT + ALT + DOWN", hl.dsp.workspace.move({ monitor = "down" }))

hl.bind("ALT + TAB", sh("hyprctl dispatch cyclenext; hyprctl dispatch bringactivetotop"))
hl.bind("ALT + SHIFT + TAB", sh("hyprctl dispatch cyclenext prev; hyprctl dispatch bringactivetotop"))

hl.bind(mod .. " + CTRL + code:20", sh("hyprctl dispatch resizeactive -100 0"))
hl.bind(mod .. " + CTRL + code:21", sh("hyprctl dispatch resizeactive 100 0"))
hl.bind(mod .. " + CTRL + SHIFT + code:20", sh("hyprctl dispatch resizeactive 0 -100"))
hl.bind(mod .. " + CTRL + SHIFT + code:21", sh("hyprctl dispatch resizeactive 0 100"))

-- open file manager
bind_app(mod .. " + SHIFT + F", "nautilus")
bind_app(mod .. " + SHIFT + B", "xdg-open about:blank")
-- open Neovim
bind_app(mod .. " + SHIFT + N", "nvim")
bind_app(mod .. " + SHIFT + D", terminal .. " lazydocker")
bind_app(mod .. " + SHIFT + O", "obsidian")
bind_app(mod .. " + SHIFT + W", "typora --enable-wayland-ime")
hl.bind("XF86Display", sh("monitor"), { locked = true, repeating = true })
hl.bind(mod .. " + CTRL + D", sh("monitor"))
hl.bind(mod .. " + CTRL + W", sh("qs ipc call network toggle"))
hl.bind(mod .. " + CTRL + A", sh("pavucontrol"))
hl.bind(mod .. " + CTRL + P", sh("qs ipc call session confirmExit"))
hl.bind(mod .. " + CTRL + L", sh("qs ipc call lock lock"), { locked = true })
bind_app(mod .. " + I", terminal .. " htop")

hl.bind("XF86AudioRaiseVolume", sh("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", sh("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", sh("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", sh("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", sh("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", sh("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", sh("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", sh("playerctl previous"), { locked = true })
hl.bind("XF86KbdBrightnessUp", sh("brightnessctl -d 'dell::kbd_backlight' set +1"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", sh("brightnessctl -d 'dell::kbd_backlight' set 1-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", sh("brightnessctl set +20%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", sh("brightnessctl set 20%-"), { locked = true, repeating = true })
hl.bind("PRINT", sh("screenshot-wayland edit"))
hl.bind(mod .. " + PRINT", sh("command -v hyprpicker >/dev/null 2>&1 && hyprpicker -a || notify-send 'Hyprland modern profile' 'hyprpicker is not installed'"))
