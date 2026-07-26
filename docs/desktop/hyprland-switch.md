# Hyprland switch

Mini runbook for the active Wayland setup. The old X11 setup is archived, not deployed by default.

## Profiles

- `HYPR_PROFILE=default`: Hyprland profile that stays close to the current i3 workflow.
- `HYPR_PROFILE=omarchy`: Omarchy-like Hyprland profile, with the local Quickshell shell owning surfaces.

If `HYPR_PROFILE` is unset, `default` is used.

## Prepare

Copy the dotfiles into `$HOME`:

```console
home -y
```

Check required commands and current session:

```console
hypr-session smoke
```

## Test

Validate the default Hyprland profile:

```console
hypr-session test
```

Validate the Omarchy-like Wayland profile:

```console
HYPR_PROFILE=omarchy hypr-session test
```

Inside Hyprland, reload after config changes:

```console
hypr-session reload
```


## Login Manager

This machine has GDM autologin enabled for `marcelof`. Run the full helper path because `sudo` does not include `~/bin` in `PATH`:

```console
sudo /home/marcelof/bin/hypr-gdm install
```

GDM and SDDM discover Wayland sessions from `/usr/share/wayland-sessions/*.desktop`. The helper installs `/usr/share/wayland-sessions/hyprland.desktop` with:

- `Name=Hyprland`
- `Exec=/home/marcelof/bin/hypr-session start`
- `TryExec=/home/marcelof/.nix-profile/bin/start-hyprland`

For GDM, the helper also sets `Session=hyprland` and `XSession=hyprland` in `/var/lib/AccountsService/users/marcelof`, writes `~/.dmrc`, and re-enables Wayland if `/etc/gdm3/custom.conf` had `WaylandEnable=false`. With autologin still enabled, reboot should enter Hyprland directly. To choose manually at boot, disable GDM autologin first.

SDDM uses the same `/usr/share/wayland-sessions/hyprland.desktop` chooser entry, but this helper does not edit SDDM config.

Tracked source of truth:

- `desktop/bin/hypr-gdm`: creates/removes login-manager files.
- `desktop/bin/hypr-session`: starts, tests, and reloads Hyprland.
- `desktop/.config/hypr/init.lua`: active Hyprland entrypoint.
- `desktop/.config/hypr/profiles/default.lua` and `desktop/.config/hypr/profiles/omarchy.lua`: selectable profiles.


## X11 archive

The old X11 setup is archived under `archive/x11/desktop/`:

- `.config/i3`
- `.config/polybar`
- `.config/rofi`
- `.config/picom`
- `bin/ddspawn`

The archive is intentionally outside the active `desktop/` tree so `home -y`
does not redeploy it. This migration has no active X11 fallback path.
