-- Hyprland 0.55+ Lua config.
-- Keep this additive to the i3 config so X11 rollback stays trivial.

local mod = "SUPER"
local terminal = "hypr-term"
local launcher = "qs-launcher"
local function sh(cmd)
  return hl.dsp.exec_cmd(cmd)
end

local function note(message)
  return sh("notify-send 'Hyprland default profile' " .. string.format("%q", message))
end

local function noop()
  return function() end
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

local function universal_paste()
  if active_window_is_terminal() then
    send_shortcut_once("SHIFT", "Insert")()
  else
    send_shortcut_once("CTRL", "V")()
  end
end

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto-right", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = false,
      disable_while_typing = true,
    },
  },

  general = {
    gaps_in = 8,
    gaps_out = 12,
    border_size = 1,
    layout = "dwindle",
    ["col.active_border"] = "rgba(b4befeff)",
    ["col.inactive_border"] = "rgba(313244ff)",
  },
  group = {
    col = {
      border_active = "rgba(b4befeff)",
      border_inactive = "rgba(313244ff)",
    },
    groupbar = {
      font_family = "FiraCode Nerd Font",
      font_size = 12,
      height = 22,
      indicator_height = 2,
      indicator_gap = 5,
      gaps_in = 5,
      gaps_out = 0,
      text_color = "rgb(cdd6f4)",
      text_color_inactive = "rgba(cdd6f490)",
      col = {
        active = "rgba(313244dd)",
        inactive = "rgba(1e1e2edd)",
      },
    },
  },


  decoration = {
    rounding = 10,
    blur = {
      enabled = true,
      size = 4,
      passes = 2,
    },
  },

  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = true,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

hl.workspace_rule({ workspace = "3", monitor = "DP-2" })

hl.window_rule({ match = { title = "hypr-floating" }, float = true, size = { 800, 600 }, center = true })
hl.window_rule({ match = { class = "floating" }, float = true, size = { 800, 600 }, center = true })
hl.window_rule({ match = { title = "quickshell-launcher" }, float = true, size = { 720, 520 }, center = true })
hl.window_rule({ match = { title = "quickshell-websearch" }, float = true, size = { 640, 220 }, center = true })
hl.window_rule({ match = { class = "Terminator" }, workspace = "4" })
hl.window_rule({ match = { class = "Slack" }, workspace = "5" })
hl.window_rule({ match = { class = "Spotify" }, workspace = "7" })
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, border_size = 1 })
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

hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + W", hl.dsp.window.close())

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + LEFT", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + DOWN", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + UP", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + RIGHT", hl.dsp.focus({ direction = "right" }))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }))

hl.bind(mod .. " + Z", hl.dsp.layout("splith"))
hl.bind(mod .. " + V", universal_paste)
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.layout("splitv"))
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SPACE", sh(launcher))
hl.bind(mod .. " + A", note("focus parent has no dwindle equivalent yet"))
hl.bind(mod .. " + S", sh("hypr-scratch toggle"))
hl.bind(mod .. " + ALT + S", sh("hypr-scratch move"))
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mod .. " + ALT + LEFT", hl.dsp.window.move({ into_group = "l" }))
hl.bind(mod .. " + ALT + RIGHT", hl.dsp.window.move({ into_group = "r" }))
hl.bind(mod .. " + ALT + UP", hl.dsp.window.move({ into_group = "u" }))
hl.bind(mod .. " + ALT + DOWN", hl.dsp.window.move({ into_group = "d" }))
hl.bind(mod .. " + ALT + TAB", hl.dsp.group.next())
hl.bind(mod .. " + ALT + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mod .. " + R", note("resize mode is mapped to SUPER+CTRL+h/j/k/l"))
hl.bind(mod .. " + CTRL + H", sh("hyprctl dispatch resizeactive -10 0"))
hl.bind(mod .. " + CTRL + J", sh("hyprctl dispatch resizeactive 0 10"))
hl.bind(mod .. " + CTRL + K", sh("hyprctl dispatch resizeactive 0 -10"))
hl.bind(mod .. " + CTRL + L", sh("hyprctl dispatch resizeactive 10 0"))

hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mod .. " + SHIFT + PERIOD", hl.dsp.workspace.move({ monitor = "+1" }))

for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local workspace = tostring(i)
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mod .. " + SHIFT + C", sh("hypr-session reload"))
hl.bind(mod .. " + SHIFT + R", sh("hypr-session reload"))
hl.bind(mod .. " + SHIFT + E", sh("/home/marcelof/bin/qs-bar power"))
hl.bind(mod .. " + ESCAPE", sh("/home/marcelof/bin/qs-bar power"))
hl.bind(mod .. " + SLASH", sh("/home/marcelof/bin/qs-bar keybindings"))
hl.bind(mod .. " + CTRL + A", sh("/home/marcelof/bin/qs-bar controls"))
hl.bind(mod .. " + CTRL + V", noop())
hl.bind(mod .. " + CTRL + W", noop())
hl.bind(mod .. " + ALT + L", sh("/home/marcelof/bin/qs-bar lock"), { locked = true })

-- open terminal
hl.bind(mod .. " + RETURN", sh(terminal))
hl.bind(mod .. " + U", sh("/home/marcelof/bin/hypr-popup-tmux"))
-- open app launcher
hl.bind(mod .. " + D", sh(launcher))
-- search the web
hl.bind(mod .. " + comma", sh("/home/marcelof/bin/qs-bar websearch"))
hl.bind("XF86Display", sh("monitor"))
hl.bind(mod .. " + P", sh("monitor"))
-- open system monitor
hl.bind(mod .. " + I", sh(terminal .. " htop"))

hl.bind("XF86AudioRaiseVolume", sh("pactl set-sink-volume @DEFAULT_SINK@ +10%"))
hl.bind("XF86AudioLowerVolume", sh("pactl set-sink-volume @DEFAULT_SINK@ -10%"))
hl.bind("XF86AudioMute", sh("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioMicMute", sh("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))
hl.bind(mod .. " + M", sh("/home/marcelof/bin/audioctl play-pause-all"))
hl.bind("XF86AudioPause", sh("/home/marcelof/bin/audioctl play-pause-all"))
hl.bind("XF86AudioPlay", sh("/home/marcelof/bin/audioctl play-pause-all"))
hl.bind("XF86KbdBrightnessUp", sh("brightnessctl -d 'dell::kbd_backlight' set +1"))
hl.bind("XF86KbdBrightnessDown", sh("brightnessctl -d 'dell::kbd_backlight' set 1-"))
hl.bind("XF86MonBrightnessUp", sh("/home/marcelof/bin/bri +10"))
hl.bind("XF86MonBrightnessDown", sh("/home/marcelof/bin/bri -10"))
hl.bind("PRINT", sh("screenshot-wayland edit"))
