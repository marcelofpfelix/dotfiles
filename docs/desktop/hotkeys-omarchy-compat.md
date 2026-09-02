# Omarchy Hotkey Compatibility

Source snapshot: local Omarchy Quattro manual files under `/tmp/omarchy-quattro/manual/04-navigation.md` and `/tmp/omarchy-quattro/manual/07-hotkeys.md`, compared with generated local output from:

```console
hypr-keys default
hypr-keys omarchy
```

Keep `desktop/bin/hypr-keys` as the source of truth for current bindings. This file records category decisions only; do not duplicate every generated key here.

## Category Decisions

- Navigation and tiling
  - Default: keeps i3-like focus/move, split, workspace, scratchpad, resize, and close behavior.
  - Omarchy profile: adds Omarchy-like floating, pseudo, pinned floating, Alt-Tab, group navigation, workspace scroll, and monitor workspace movement.
  - Decision: compatible enough. Do not change default; it must stay i3-migration friendly.

- System controls
  - Default: exposes Controls, Screen, Network, Calendar, Power, and Settings mostly through `Win+Ctrl+A` hub plus bar clicks.
  - Omarchy profile: now has direct `Win+Ctrl+A/B/C/D/P/L`, `Win+Ctrl+Space`, and `Win+Ctrl+Shift+Space` shortcuts where local surfaces exist.
  - Decision: direct shortcuts belong in `omarchy`; default keeps the smaller hub model.

- Notifications and notices
  - Default: bar/Controls-first, with `qbar notice` available from scripts.
  - Omarchy profile: now has DND, notification history, and time/weather/battery notice shortcuts.
  - Decision: adopted useful non-destructive bindings. Latest-notification invoke/dismiss stays unbound until local notification action replay is complete.

- Apps
  - Default: terminal, launcher, web search, monitor, and htop match the migrated i3 workflow.
  - Omarchy profile: keeps common direct app launchers already supported locally: browser, files, Neovim, Lazydocker, Obsidian, Typora.
  - Decision: do not add Omarchy web-app-specific bindings for apps that are not local defaults.

- Clipboard
  - Default: keeps `Win+V` terminal-aware paste and reserves `Win+Ctrl+V` as a blocker.
  - Omarchy profile: keeps universal `Win+C/V/X` and the same blocker for `Win+Ctrl+V` because the user explicitly rejected duplicate clipboard bindings.
  - Decision: compatible by intent, not exact Omarchy behavior.

- Capture
  - Default: `Print` opens screenshot edit; Screen panel is reachable through Controls.
  - Omarchy profile: adds `Win+Ctrl+C` for the local Screen panel and keeps `Win+Print` color picker.
  - Decision: adopted only surfaces that exist locally. OCR remains inside the Screen panel.

- Style
  - Default: Settings and Wallpaper are reachable through Controls.
  - Omarchy profile: `Win+Ctrl+Space` opens Wallpaper and `Win+Ctrl+Shift+Space` opens Settings.
  - Decision: adopted local equivalents without a theme marketplace or full theme engine.

- Toggles, reminders, and hardware
  - Default: Awake/DND/display live in Controls/bar actions.
  - Omarchy profile: DND and display have direct bindings; reminders live in Calendar because there is no input popup yet.
  - Decision: do not bind destructive clear-all reminder actions or hardware toggles without confirmation.

## Adopted Free Omarchy-Like Bindings

- `Win+Ctrl+B`: Controls, because Bluetooth lives there locally.
- `Win+Ctrl+C`: Screen panel.
- `Win+Ctrl+Space`: Wallpaper.
- `Win+Ctrl+Shift+Space`: Settings/theme state.
- `Win+Shift+Alt+,`: Notifications.
- `Win+Ctrl+,`: Toggle DND.
- `Win+Ctrl+Alt+T`: Time notice.
- `Win+Ctrl+Alt+B`: Battery notice.
- `Win+Ctrl+Alt+W`: Weather notice.

## Deliberately Not Adopted

- `Win+,` notification dismiss: conflicts with the local default web-search muscle memory.
- `Win+Ctrl+V` clipboard manager: explicitly kept as a blocker to avoid duplicate/accidental paste behavior.
- `Win+Ctrl+R` set reminder: needs a real input popup first.
- Reminder clear-all hotkey: destructive without confirmation.
- Omarchy web-app bindings: only add when the app is a local default and the binding is wanted.
- Monitor scale/lid/mirror hotkeys: wait for confirmed local monitor workflow and explicit confirmation.
