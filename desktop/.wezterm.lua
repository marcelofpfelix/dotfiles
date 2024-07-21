-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
config.color_scheme = 'catppuccin-mocha'
-- config.color_scheme = 'Dracula (Official)'

config.font = wezterm.font 'Fira Code'
config.font_size = 10.0
config.enable_tab_bar = false
config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'

config.keys = {
  {
    key = 'f',
    mods = 'CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

config.mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}


-- and finally, return the configuration to wezterm
return config
