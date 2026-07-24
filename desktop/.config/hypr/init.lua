-- Select one local Hyprland profile.
-- HYPR_PROFILE=default keeps behavior close to the current i3 config.
-- HYPR_PROFILE=omarchy loads an Omarchy-like Wayland profile with extra desktop shortcuts.

local profile = os.getenv("HYPR_PROFILE") or "default"

if profile ~= "default" and profile ~= "omarchy" then
  error("unknown HYPR_PROFILE: " .. profile)
end

require("profiles." .. profile)
