# Wayland parity tasks

## Profiles

- [x] Keep exactly two Hyprland profiles: `default` and `omarchy`.
- [x] Make `default` the i3-compatible migration profile.
- [x] Make `omarchy` provide similar Wayland-first behavior without upstream runtime binaries.
- [x] Start Hyprland through the documented `start-hyprland -- --config ...` path.
- [x] Install/require `nixGL` for Nix-packaged Hyprland on Ubuntu.
- [x] Add GDM session integration with rollback through `hypr-gdm`.

## Default profile parity

- [x] `Win+Enter` opens Ghostty.
- [x] `Win+D` opens the Quickshell fuzzy application launcher.
- [x] `Win+A` has an explicit i3-parity notice for unsupported focus-parent behavior.
- [x] `Win+W` closes the focused window, matching the Omarchy quattro binding accepted for this migration.
- [x] `Win+S` uses the local `hypr-scratch` helper and `Win+Alt+S` moves the active window there.
- [x] `Win+U` is intentionally unbound for now; the terminal-backed dropdown path is not reliable enough under Wayland.
- [x] `Win+R` reports the resize replacement.
- [x] `Win+Space` opens the Quickshell launcher; the old floating-focus behavior is not kept because app launch is the accepted default.
- [x] `Win+Shift+E` uses the Quickshell exit confirmation instead of exiting immediately.
- [x] `Win+Alt+L` calls the Quickshell lock IPC target so `Win+Ctrl+L` can stay resize-right.
- [x] `Win+Ctrl+A` opens the Quickshell controls popup, which now acts as the all-menus hub.
- [x] Network is reachable from the Quickshell controls menu instead of `Win+Ctrl+W`, which conflicts with app close-tab/window behavior.

## Omarchy profile parity

- [x] `Win+Space` opens the local Quickshell launcher through `qs ipc call launcher toggle`/`qs-launcher`.
- [x] `Win+W` closes the focused window like Omarchy quattro.
- [x] `Win+S` uses the local `hypr-scratch` helper and `Win+Alt+S` moves a window there.
- [x] `Win+Escape` and `Win+Shift+E` open the local Quickshell exit confirmation.
- [x] `Win+Ctrl+L` calls the local Quickshell lock IPC target.
- [x] The local Quickshell controls menu opens the network panel through `qs ipc call network toggle`.
- [x] `Win+K` opens local Quickshell keybindings, matching Omarchy quattro behavior without upstream binaries.
- [x] `Win+Ctrl+A` opens local Quickshell controls/audio, matching Omarchy quattro intent without upstream binaries.
- [x] `Win+Shift+Space` toggles the local Quickshell bar.
- [x] `Win+G`, `Win+Alt+G`, `Win+Alt+Arrows`, and `Win+Alt+Tab` use native Hyprland groups.
- [x] `Win+Shift+Arrows` swaps windows like Omarchy quattro.
- [x] `Alt+Volume` and `Alt+Brightness` provide precise native adjustments.
- [x] `Win+C`, `Win+V`, and `Win+X` provide universal clipboard shortcuts without external shell IPC.
- [x] Avoid upstream runtime binaries; implement similar behavior with generic tools and local Quickshell IPC.
- [x] Use local Quickshell IPC and common Wayland apps/CLIs for launcher, network, lock, screenshot, audio, and related actions.
- [x] Media playback keys use generic `playerctl`; volume and brightness use `pactl` and `brightnessctl`.
- [x] Clipboard history is available from the Quickshell controls menu backed by `cliphist decode | wl-copy`; `cliphist`, `wl-copy`, and `wl-paste` are tracked.

## Quickshell replacements

- [x] Replace the main rofi app launcher with a Quickshell fuzzy launcher.
- [x] Replace the Polybar workspace/status/tray surface with Quickshell.
- [x] Render Polybar color markup through `BAR_COLOR_FORMAT=quickshell` for Quickshell status text.
- [x] Put wallpaper ownership in Quickshell startup.
- [x] Put system tray ownership in Quickshell startup.
- [x] Add a Quickshell-owned network panel and status segment.
- [x] Add a Quickshell-owned lock IPC command using `hyprlock`, `swaylock`, or `loginctl lock-session`.
- [x] Keep secure locking delegated to a real Wayland locker instead of faking a lock window.
- [x] Replace Wayland rofi/dmenu/zenity utility paths in `passmenu` and `rcal` with Quickshell-owned popups.
- [x] Add a native Quickshell calendar popup with month navigation, today highlighting, Lisbon time context, and todo detail area.
- [x] Add a Quickshell password picker popup for `passmenu` parity: fuzzy entry filtering, copy password, type password, type username, and type entry name.
- [x] Replace X11 monitor toggling with a Hyprland-aware `monitor` path.
- [x] Add optional `cliphist-menu watch` startup guarded by `command -v cliphist`.
- [x] `gocode` and `gowork` are Hyprland-only under this desktop profile.

## Validation

- [x] `bash -n` passes for touched shell helpers.
- [x] `luac -p` passes for Hyprland Lua profiles.
- [x] `qmllint` passes for local Quickshell QML.
- [x] `Hyprland --config desktop/.config/hypr/init.lua --verify-config` passes for `default`.
- [x] `HYPR_PROFILE=omarchy Hyprland --config desktop/.config/hypr/init.lua --verify-config` passes for `omarchy`.
- [x] Live files under `$HOME/.config/hypr`, `$HOME/.config/quickshell`, `$HOME/bin`, and `$HOME/lib` are refreshed from the repo.
- [x] Safe color-format sample proves Quickshell rich text and plain output modes.
- [x] `hypr-session status` checks the required Wayland runtime tools tracked in homelab and reports optional `hyprpicker` separately.

## References

- Caelestia shell: https://github.com/caelestia-dots/shell
  - Useful ideas to study: Quickshell IPC command surface, structured config files, notification drawers, MPRIS controls, wallpaper handling, and per-monitor config patterns. Do not copy binaries or adopt its CLI/runtime naming.
- Caelestia dots: https://github.com/caelestia-dots/caelestia (about 3.8k stars; local `/tmp/quickshell-refs/caelestia`)
  - Useful ideas reviewed: Lua Hyprland config split, shell restart/session/media bindings, configurable special-workspace app placement, workspace group movement, and keeping shell actions behind a small IPC surface. Do not copy its runtime package names or assume its install layout.
- end-4 dots-hyprland: https://github.com/end-4/dots-hyprland (about 15k stars)
  - Useful ideas to study: high-polish Quickshell overview, Material-style quick settings, notification surfaces, wallpaper-driven theming, and search panels. Keep local behavior i3-compatible first.
- Noctalia shell: https://github.com/noctalia-dev/noctalia-shell (about 7.4k stars on the main Noctalia repo)
  - Useful ideas to study: all-in-one Quickshell bar, notification center, control center, launcher, lock screen, power menu, brightness controls, audio controls, widgets, and plugin-style extension points. Avoid depending on its forked runtime unless this repo explicitly chooses that later.
- cxOrz dotfiles-hyprland: https://github.com/cxOrz/dotfiles-hyprland (about 200 stars; lower priority, useful for concrete module layout)
  - Useful ideas to study: ChromeOS-style control center, power menu, notification UI, shelf/workspaces, Wi-Fi/Bluetooth/volume/brightness controls, and launcher ergonomics.
- Aylur AGS/dotfiles ecosystem: https://github.com/Aylur/ags and https://aylur.github.io/ags/ (local `/tmp/quickshell-refs/ags`)
  - Useful ideas reviewed: service-style widgets, listen-vs-poll patterns, notification/media/network services, click-away launcher behavior, Alt-number launcher selection, and app-shell ergonomics. Keep this repo Quickshell-first; do not add AGS/Astal for this migration.
- Omarchy v4 migration note: user reports Omarchy will migrate to Quickshell in v4; this is not in public docs yet, so treat it as directionally useful but unverified until upstream publishes it.

- Omarchy quattro local reference: `/tmp/omarchy-quattro`
  - Useful ideas reviewed: native Hyprland scratchpad, group bindings, groupbar styling, system/keybinding menu shortcuts, and tray/menu interaction patterns. Do not copy upstream command names or runtime binaries.
- surface-dots: https://github.com/snes19xx/surface-dots
  - Useful ideas reviewed: Hyprland-first session/login assumptions and SDDM session presentation. It did not add a better Quickshell group/scratch implementation for this repo.
- ilyamiro nixos-configuration: https://github.com/ilyamiro/nixos-configuration
  - Useful ideas reviewed: `hyprctl` workspace state generation, event-triggered refresh, and Quickshell workspace rendering. Reuse the idea of state from native Hyprland JSON without adopting the full cache daemon here.

## Reference-derived implementation tasks

- [x] Reduce polling in the Quickshell bar using native/event state.
  - Source: ilyamiro `hyprctl` workspace JSON plus socket-triggered refresh.
  - Keep it small: use the existing local helper model first; add a daemon only if measured polling cost is visible.
  - Acceptance: workspace/group/scratch indicators update from `hypr-state watch` on Hyprland socket events without a 1s timer.
- [x] Improve the Quickshell notification center layout from polished reference shells.
  - Sources: Omarchy quattro notification service/card split, Noctalia compact notification center, end-4 notification surfaces.
  - Keep local implementation in the existing single shell unless one extracted component clearly shrinks the file.
  - Acceptance: long app/body/action text never overflows collapsed rows; actions remain clickable; clear-one and clear-all still work.
- [x] Tighten the control center layout and controls.
  - Sources: Noctalia all-in-one controls, cxOrz ChromeOS-style quick settings, end-4 quick settings polish.
  - Keep the current local helpers for audio, brightness, network, Bluetooth, and power.
  - Acceptance: audio stream rows, brightness, network, Bluetooth, and power controls use consistent row heights, icons, hover states, and no dead right-side space.
- [x] Build a main Quickshell control dashboard.
  - Sources: Noctalia dashboard/control center, cxOrz ChromeOS-style quick settings, end-4 quick settings.
  - Acceptance: one dashboard exposes audio mixer, player controls, brightness, network, Bluetooth, power profile, battery health, screenshot, lock, and suspend without replacing the smaller popups; recording stays in the screen-record task until a recorder is installed.
- [x] Polish launcher interaction using already-proven app-shell behavior.
  - Sources: AGS launcher example and current Quickshell launcher.
  - Acceptance: launcher closes on Escape, supports direct `Alt+1..9` selection, and keeps MRU/MFU ordering.
- [x] Revisit launcher click-away close only if it can keep the current floating input behavior.
  - Source: AGS full-screen launcher backdrop.
  - Current behavior: launcher, clipboard picker, and web search stay as focused floating Quickshell windows and close when Hyprland clears their focus grab after an outside click.
  - Acceptance: outside click closes the launcher without returning to the earlier no-input/side-window failure mode.
- [x] Split a media dashboard from the control dashboard if the control popup gets crowded.
  - Sources: Caelestia MPRIS controls, AGS/Astal MPRIS service model, Noctalia media widgets.
  - Acceptance: `qs-bar media` and audio right-click open a dedicated media popup with previous/play-next, pause-all, local noise/music state, stream volume controls, and pavucontrol output switching.
- [x] Build a notification dashboard/inbox.
  - Sources: Omarchy quattro notification service/card split, Noctalia notification center, AGS notification popup replacement behavior.
  - Current behavior: existing center groups recent notifications by app, preserves notification actions, and supports clear-one, clear-app, and clear-all.
  - Acceptance: group by app, show seen/unseen or recent sections, preserve actions, clear one app, clear all.
- [x] Add a small wallpaper/theme popup only if it uses existing local tools.
  - Sources: Caelestia structured config/wallpaper handling, end-4 wallpaper/theme panels.
  - Do not add a theme engine or upstream runtime naming.
  - Acceptance: choose from local wallpapers, apply via the current Wayland wallpaper path, and persist only the selected file/theme token.
  - Current behavior: `qs-bar wallpaper` lists local files from `~/.local/share/backgrounds` and `~/Pictures/Wallpapers`, previews the active wallpaper, applies it through Quickshell, and persists the path in Quickshell state.
- [x] Add screen-record/share utility popup.
  - Sources: Omarchy quattro share/menu bindings, end-4 utility surfaces.
  - Prefer native tools already tracked for screenshots and portals.
  - Current behavior: `qs-bar screen` opens a Quickshell popup for screenshot edit/copy/save/full/window, recording start/stop/open/copy-path, and portal status. `wf-recorder` is installed live and tracked in homelab install intent.
  - Acceptance: expose screenshot, screen record start/stop, copy/open result, and portal status without rofi/zenity.
- [x] Add OCR/share only after the screenshot/recording popup exists.
  - Sources: Omarchy-style share flow and end-4 utility UI.
  - Acceptance: selected screenshot can be OCR'd or shared using installed open tools; no extra service stays running.
  - Current behavior: `screenshot-wayland ocr` OCRs a selected area to clipboard using `grim`, `slurp`, `tesseract`, and `wl-copy`; the Screen popup also opens/copies the last saved screenshot path.
- [x] Make keybinding help generated from Hyprland profile data.
  - Sources: Omarchy quattro generated keybinding menu concept.
  - Acceptance: `Win+/` reflects `default`/`omarchy` bindings through `hypr-keys`, without manually duplicating the list in QML.
- [x] Defer a scratchpad dashboard until scratchpad use is proven.
  - Sources: Omarchy/Caelestia special workspace patterns.
  - Current behavior: `Win+S` toggles the helper-backed `special:scratchpad`, `Win+Alt+S` moves the active window there, and Quickshell shows the scratchpad count without exposing it as a numbered workspace.
  - Decision: no dashboard yet; build it only if repeated scratchpad use needs window selection.
  - Acceptance: show scratchpad windows, focus one, move active window there, and move all out.
- [x] Defer named special-workspace app placement until scratchpad use grows.
  - Source: Caelestia configurable special workspace apps.
  - Decision: no named special-workspace app rules yet; document the pattern only after there is a repeated app set.
  - Acceptance: no new special workspace is added until there is a real repeated app set; document the pattern first.
- [x] Improve session/login documentation, not runtime code.
  - Source: surface-dots session/login presentation.
  - Current behavior: `hypr-gdm install` creates the login-manager session file and updates GDM account defaults; the repo tracks the helper and Hyprland entrypoint, not `/usr/share` or `/var/lib` generated state.
  - Acceptance: docs explain how GDM/SDDM discover the Hyprland session and where this dotfiles repo tracks the session files.

## Follow-up

- [x] Build a Quickshell power/session popup for `lock`, `logout`, `suspend`, `hibernate`, `reboot`, and `shutdown`.
  - Use native commands behind a local helper or IPC target: `loginctl lock-session`, `hyprctl dispatch exit`, `systemctl suspend`, `systemctl hibernate`, `systemctl reboot`, and `systemctl poweroff`.
  - Require confirmation for `logout`, `hibernate`, `reboot`, and `shutdown`.
  - Wire `Win+Shift+E` to this popup in the i3-compatible default profile instead of the current exit-only confirmation.
  - Add one common secondary binding, such as `Ctrl+Alt+Delete` or `Win+Delete`, only if it does not conflict with existing i3 parity.
- [x] Build a Quickshell keybindings popup.
  - Show the active profile plus launcher, terminal, movement, workspaces, screenshots, audio, brightness, network, calendar, notifications, scratchpad, reload, and power actions.
  - Bind it to a free key such as `Win+/` or `Win+Ctrl+K`.
  - Generate or source the content close to the Hyprland profile data so it does not drift.
- [x] Finish the rofi/dmenu/zenity migration audit for Wayland.
  - Move i3, polybar, rofi, picom, and `ddspawn` to `archive/x11` so they are not redeployed.
  - Make `passmenu` Quickshell-only under the active Wayland desktop profile.
  - Keep `rcal` opening the native Quickshell calendar under Wayland and plain `cal -3` outside a graphical session.
  - Validate that Hyprland startup, Quickshell actions, and Wayland helpers do not hard-call rofi, dmenu, or zenity.
- [x] Add a Quickshell clipboard history picker.
  - Replace `cliphist-menu` Wayland zenity/fzf selection with a Quickshell fuzzy popup.
  - Keep `cliphist decode | wl-copy` as the backend action after selection.
  - Keep clipboard selection Quickshell-owned for the active Wayland desktop profile.
- [x] Replace the old `Win+,` rofi websearch path with direct Quickshell web-search IPC; keep `websearch` only as a CLI helper.
- [x] Expand the Quickshell control center.
  - [x] Audio popup has per-stream mute/volume, active stream metadata, pavucontrol launch, noise, stop, and play/pause-all actions.
  - [x] Keep the top bar audio control icon-only; put details in the popup.
  - [x] Add screen brightness controls where hardware support exists.
  - [x] Add keyboard brightness controls where hardware support exists.
  - [x] Add richer network and Bluetooth status/toggles using native services.
  - [x] Add power profile and battery health only if the local native service is available.
- [x] Improve the local Quickshell notification center basics.
  - Popup toasts, expandable notification details, action buttons, clear-one, clear-all, and app labels are implemented.
  - Local `notify-send -A` no longer reports missing action support.
- [x] Verify Chrome and Brave native notifications after a full browser restart.
  - Current behavior: fresh temp-profile launches through `chrome-wayland` and `brave-wayland` emitted `org.freedesktop.Notifications.Notify` on D-Bus for service-worker notifications.
- [x] Evaluate Hyprland groups as the closest native replacement for i3 tabbed/stacked containers.
  - Groupbar styling is enabled in both profiles and Quickshell shows active grouped-window count.
- [x] Improve scratchpad/dropdown behavior.
  - `Win+S` scratchpad count is visible beside workspaces without showing special workspaces as numbered workspaces.
  - Revisit a `Win+U` dropdown terminal only if terminal class/title matching is reliable.

- [x] Verify browser WebGL through fresh wrapper-launched Chrome and Brave profiles.
  - Current behavior: `chrome-wayland` and `brave-wayland` both expose WebGL 2 through ANGLE on Intel Iris Xe under Hyprland. The wrappers still log a Vulkan compatibility warning, but WebGL works.
  - Decision: do not add `--use-gl=egl`, `--use-angle=opengl`, or `--use-gl=angle --use-angle=opengl`; all three broke WebGL in the smoke test.
- [x] Keep Chrome and Brave on conservative Wayland/PipeWire flags with Vulkan disabled unless `chrome://gpu` proves the Vulkan path is stable under Hyprland.
  - Current behavior: live Chrome and fresh Chrome/Brave test launches keep `--ozone-platform=wayland`, `--enable-native-notifications`, `UseOzonePlatform`, `WebRTCPipeWireCapturer`, `--disable-features=Vulkan`, and `--disable-vulkan`.
- [x] Review Electron apps for Wayland/PipeWire wrappers: Slack first, then 1Password, Obsidian, Zed-like editors, Discord/Zoom if installed.
  - Current behavior: Slack, 1Password, Discord, and Obsidian launch through local Wayland wrappers that unset inherited Nix/Mesa loader state and pass `--ozone-platform=wayland` plus `UseOzonePlatform,WebRTCPipeWireCapturer`.
  - Decision: Zed is already a native local app, and Zoom uses its own `/opt/zoom/ZoomLauncher`; no Electron flags are forced into either.

## Notes

- `default` is the i3-compatible profile. There is intentionally no separate `i3` profile.
- Quickshell owns bar, launcher, tray, wallpaper, controls, calendar, notification history, network panel, lock IPC, and exit confirmation; controls also acts as the all-menus hub.
- Both profiles use the local lightweight Quickshell shell. The `omarchy` profile does not install or call upstream runtime binaries.
- Adapted reference patterns already landed locally: Caelestia-like session actions behind local commands, end-4-like `Super+/` keybinding help and cliphist watcher refresh, Noctalia-like compact popup/control surfaces, and cxOrz-like cliphist as backend plumbing.
- Rust system-metrics helper is intentionally not active work. The future note lives in `wiki/main/resources/dev/desktop.md`; build it only if measured Quickshell status polling cost becomes a real problem.
