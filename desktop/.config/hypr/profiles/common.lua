local M = {}

M.actions = {
  hypr_reload = "hypr-session reload",
  keybindings = "keybindings",
  play_pause_all = "play-pause-all",
}

M.classes = {
  ghostty = "com.mitchellh.ghostty",
}

M.colors = {
  border_active = "rgba(b4befeff)",
  border_inactive = "rgba(313244ff)",
  groupbar_active = "rgba(313244dd)",
  groupbar_inactive = "rgba(1e1e2edd)",
  text = "rgb(cdd6f4)",
  text_inactive = "rgba(cdd6f490)",
}

M.terminal_classes = {
  alacritty = true,
  [M.classes.ghostty] = true,
  foot = true,
  kitty = true,
  wezterm = true,
}


M.arrow_directions = {
  { key = "LEFT", direction = "left" },
  { key = "DOWN", direction = "down" },
  { key = "UP", direction = "up" },
  { key = "RIGHT", direction = "right" },
}

M.vim_directions = {
  { key = "H", direction = "left" },
  { key = "J", direction = "down" },
  { key = "K", direction = "up" },
  { key = "L", direction = "right" },
}

function M.group_config()
  return {
    col = {
      border_active = M.colors.border_active,
      border_inactive = M.colors.border_inactive,
    },
    groupbar = {
      font_family = "FiraCode Nerd Font",
      font_size = 12,
      height = 22,
      indicator_height = 2,
      indicator_gap = 5,
      gaps_in = 5,
      gaps_out = 0,
      text_color = M.colors.text,
      text_color_inactive = M.colors.text_inactive,
      col = {
        active = M.colors.groupbar_active,
        inactive = M.colors.groupbar_inactive,
      },
    },
  }
end

function M.send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

function M.active_window_is_terminal()
  local window = hl.get_active_window()
  if not window or not window.class then
    return false
  end

  return M.terminal_classes[window.class:lower()] == true
end

function M.apply_default_monitors()
  local preferred = "preferred"
  hl.monitor({ output = "eDP-1", mode = preferred, position = "auto", scale = 1 })
  hl.monitor({ output = "DP-2", mode = preferred, position = "auto-right", scale = 1 })
  hl.monitor({ output = "", mode = preferred, position = "auto", scale = 1 })
end

function M.apply_common_popup_rules()
  local rules = {
    { match = { title = "hypr-floating" }, size = { 800, 600 } },
    { match = { title = "hypr-popup-tmux" }, size = { 800, 600 } },
    { match = { class = "floating" }, size = { 800, 600 } },
    { match = { title = "quickshell-launcher" }, size = { 720, 726 } },
    { match = { title = "quickshell-clipboard" }, size = { 720, 500 } },
    { match = { title = "quickshell-passmenu" }, size = { 720, 544 } },
    { match = { title = "quickshell-websearch" }, size = { 640, 112 } },
  }

  for _, rule in ipairs(rules) do
    hl.window_rule({ match = rule.match, float = true, size = rule.size, center = true })
  end
end

function M.apply_dropdown_rules()
  local options = { float = true, pin = true, size = { 625, 450 }, center = true }
  hl.window_rule({ match = { title = "dropdown_tmuxa" }, float = options.float, pin = options.pin, size = options.size, center = options.center })
  hl.window_rule({ match = { class = "dropdown_tmuxa" }, workspace = "special:dropdown_tmuxa", float = options.float, pin = options.pin, size = options.size, center = options.center })
end

function M.bind_direction_keys(prefix, directions, dispatcher)
  for _, item in ipairs(directions) do
    hl.bind(prefix .. " + " .. item.key, dispatcher({ direction = item.direction }))
  end
end

function M.bind_workspace_numbers(mod, actions)
  for i = 1, 10 do
    local key = i == 10 and "0" or tostring(i)
    local workspace = tostring(i)

    if actions.focus then
      hl.bind(mod .. " + " .. key, actions.focus(workspace))
    end
    if actions.move then
      hl.bind(mod .. " + SHIFT + " .. key, actions.move(workspace))
    end
    if actions.move_no_follow then
      hl.bind(mod .. " + SHIFT + ALT + " .. key, actions.move_no_follow(workspace))
    end
  end
end

return M
