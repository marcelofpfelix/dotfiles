# Hyprland and Quickshell parity

This is the active gap list for replacing the old i3, Polybar, rofi, and small X11 helpers with Hyprland plus the local Quickshell shell.

## Current policy

- Active desktop path: Hyprland plus Quickshell only.
- Profiles: `default` for i3-compatible migration behavior and `omarchy` for similar Wayland-first behavior using local code and generic apps.
- X11 config is archived under `archive/x11/desktop/` and is not redeployed by `home -y`.
- No upstream Omarchy shell binaries or Omarchy-named runtime scripts are used.
- Packages must be tracked in homelab install intent, not installed ad hoc.

## Done

- Hyprland profile loader with exactly `default` and `omarchy` profiles.
- Quickshell owns the bar, launcher, tray/status surface, wallpaper, calendar, password picker, clipboard picker, web search, keybindings popup, network panel, lock IPC, and session menu.
- `gocode`, `gowork`, `monitor`, and `passmenu` are active Wayland-profile helpers with no i3, rofi, dmenu, zenity, xrandr, or feh fallback path.
- X11 i3, Polybar, rofi, picom, and `ddspawn` files are archived outside the active `desktop/` tree.
- `Win+D`, `Win+Space`, `Win+/`, `Win+Ctrl+A`, `Win+Shift+E`, `Win+W`, `Win+S`, `Win+M`, brightness keys, volume keys, screenshots, web search, and power actions are mapped through Hyprland or local Quickshell IPC; clipboard and network panels live in the controls menu to avoid `Ctrl+V`/`Ctrl+W` app conflicts.
- `.tmux.conf` conflict is resolved with the current `board render tmux tmux-top` status renderer.

## Missing parity

- No remaining Hyprland plus Quickshell parity tasks are open in `docs/desktop/wayland-tasks.md`.
- Browser GPU/WebGL and Electron wrapper follow-ups remain tracked as non-parity cleanup notes in `docs/desktop/wayland-tasks.md`.

## Quick wins completed in this pass

- Removed active X11 monitor fallback from `desktop/bin/monitor`.
- Changed `desktop/bin/check-scripts` default output from Polybar markup to plain text.
- Updated docs and cheat sheet language from fallback/rollback to archive-only.
- Added this parity checklist as the canonical missing-work list.
