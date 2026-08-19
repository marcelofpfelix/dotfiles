-- Hyprland 0.55+ Lua config.
-- Keep this additive to the i3 config so X11 rollback stays trivial.

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

local function note(message)
  return sh("notify-send 'Hyprland default profile' " .. string.format("%q", message))
end

local function noop()
  return function() end
end


common.apply_default_monitors()

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
    ["col.active_border"] = common.colors.border_active,
    ["col.inactive_border"] = common.colors.border_inactive,
  },
  group = common.group_config(),

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

common.apply_common_popup_rules()
hl.window_rule({ match = { class = "Terminator" }, workspace = "4" })
hl.window_rule({ match = { class = "Slack" }, workspace = "5" })
hl.window_rule({ match = { class = "Spotify" }, workspace = "7" })
hl.window_rule({ match = { class = common.classes.ghostty }, border_size = 1 })
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

hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + W", hl.dsp.window.close())

common.bind_direction_keys(mod, common.vim_directions, hl.dsp.focus)
common.bind_direction_keys(mod, common.arrow_directions, hl.dsp.focus)
common.bind_direction_keys(mod .. " + SHIFT", common.vim_directions, hl.dsp.window.move)
common.bind_direction_keys(mod .. " + SHIFT", common.arrow_directions, hl.dsp.window.move)

hl.bind(mod .. " + Z", hl.dsp.layout("splith"))
hl.bind(mod .. " + C", common.universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))
hl.bind(mod .. " + V", common.universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert"))
hl.bind(mod .. " + X", common.send_shortcut_once("CTRL", "X"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.layout("splitv"))
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SPACE", sh(root_menu))
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

common.bind_workspace_numbers(mod, {
  focus = function(workspace) return hl.dsp.focus({ workspace = workspace }) end,
  move = function(workspace) return hl.dsp.window.move({ workspace = workspace }) end,
})

hl.bind(mod .. " + SHIFT + C", sh(common.actions.hypr_reload))
hl.bind(mod .. " + SHIFT + R", sh(common.actions.hypr_reload))
hl.bind(mod .. " + SHIFT + E", qs("power"))
hl.bind(mod .. " + ESCAPE", qs("power"))
hl.bind(mod .. " + SLASH", qs(common.actions.keybindings))
hl.bind(mod .. " + CTRL + A", qs("controls"))
hl.bind(mod .. " + CTRL + E", qs("emojis"))
hl.bind(mod .. " + CTRL + V", noop())
hl.bind(mod .. " + CTRL + W", noop())
hl.bind(mod .. " + ALT + L", qs("lock"), { locked = true })

-- open terminal
hl.bind(mod .. " + RETURN", sh(terminal))
hl.bind(mod .. " + U", sh(terminal .. " popup-tmux"))
-- open app launcher
hl.bind(mod .. " + D", sh(launcher))
-- search the web
hl.bind(mod .. " + comma", qs("websearch"))
hl.bind("XF86Display", sh("monitor"))
hl.bind(mod .. " + P", sh("monitor"))
-- open system monitor
hl.bind(mod .. " + I", sh(terminal .. " htop"))

hl.bind("XF86AudioRaiseVolume", osd("volume-up"))
hl.bind("XF86AudioLowerVolume", osd("volume-down"))
hl.bind("XF86AudioMute", osd("mute"))
hl.bind("XF86AudioMicMute", osd("mic-mute"))
hl.bind(mod .. " + M", audio(common.actions.play_pause_all))
hl.bind("XF86AudioPause", audio(common.actions.play_pause_all))
hl.bind("XF86AudioPlay", audio(common.actions.play_pause_all))
hl.bind("XF86KbdBrightnessUp", osd("kbd-up"))
hl.bind("XF86KbdBrightnessDown", osd("kbd-down"))
hl.bind("XF86MonBrightnessUp", osd("brightness-up"))
hl.bind("XF86MonBrightnessDown", osd("brightness-down"))
hl.bind("PRINT", screenshot("edit"))
