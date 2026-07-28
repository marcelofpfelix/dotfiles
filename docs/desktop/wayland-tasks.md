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
- [x] `Win+U` toggles a floating tmux popup session through `hypr-term popup-tmux`.
- [x] `Win+R` reports the resize replacement.
- [x] `Win+Space` opens the Quickshell launcher; the old floating-focus behavior is not kept because app launch is the accepted default.
- [x] `Win+Shift+E` uses the Quickshell exit confirmation instead of exiting immediately.
- [x] `Win+Alt+L` calls the Quickshell lock IPC target so `Win+Ctrl+L` can stay resize-right.
- [x] `Win+Ctrl+A` opens the Quickshell controls popup, which now acts as the all-menus hub.
- [x] `Win+Ctrl+V` and `Win+Ctrl+W` are explicit no-op blockers so they do not fall through to `Win+V` paste or `Win+W` close.

## Omarchy profile parity

- [x] `Win+Space` opens the local Quickshell launcher through `qs ipc call launcher open`/`qs-launcher`.
- [x] `Win+W` closes the focused window like Omarchy quattro.
- [x] `Win+S` uses the local `hypr-scratch` helper and `Win+Alt+S` moves a window there.
- [x] `Win+Escape` and `Win+Shift+E` open the local Quickshell exit confirmation.
- [x] `Win+Ctrl+L` calls the local Quickshell lock IPC target.
- [x] `Win+Ctrl+V` and `Win+Ctrl+W` are explicit no-op blockers; the controls menu opens the network panel through `qs ipc call network toggle`.
- [x] `Win+K` opens local Quickshell keybindings, matching Omarchy quattro behavior without upstream binaries.
- [x] `Win+Ctrl+A` opens local Quickshell controls/audio, matching Omarchy quattro intent without upstream binaries.
- [x] `Win+Shift+Space` toggles the local Quickshell bar.
- [x] `Win+G`, `Win+Alt+G`, `Win+Alt+Arrows`, and `Win+Alt+Tab` use native Hyprland groups.
- [x] `Win+Shift+Arrows` swaps windows like Omarchy quattro.
- [x] `Alt+Volume` and `Alt+Brightness` provide precise native adjustments.
- [x] `Win+C`, `Win+V`, and `Win+X` provide universal clipboard shortcuts without external shell IPC in the Omarchy-like profile; default uses `Win+V` for terminal-aware paste and `Win+Shift+V` for vertical split.
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
- [x] Live files under `$HOME/.config/hypr`, `$HOME/.config/quickshell`, `$HOME/.config/board`, `$HOME/bin`, and `$HOME/lib` are refreshed from the repo.
- [x] Safe color-format sample proves Quickshell rich text and plain output modes.
- [x] `hypr-session status` and `hypr-session smoke` check required Wayland tools, Quickshell, board, notification owner, portals, clock sync, audio state, inactive dunst, legacy launcher masks, Hyprland/Quickshell config validity, generated keybinding help, Quickshell IPC menu targets, `qs-bar` menu commands, and optional `hyprpicker`.
- [x] `desktop-doctor` wraps the live Wayland smoke check with current profile, Quickshell status, board status, picker helper status, clipboard helper status, audio state, audioctl pause/resume/status regression checks, screenshot helper status, wallpaper helper status, screen-record status, notification-smoke readiness, and static browser wrapper flag checks.
- [x] `desktop-package-audit` verifies active Wayland helper package intent, including local `board`, is tracked in the sibling homelab install list, and `desktop-doctor` runs it.
- [x] `qs-menu-smoke` opens, captures, closes, and checks Quickshell launcher/control/media/notification/calendar/wallpaper/screen/keybinding/clipboard/websearch/network/tray/power/power-confirm menu screenshots plus `contact.png` for visual regression checks; `desktop-doctor` now fails when the latest smoke run predates live Quickshell QML.

## References

Reference review snapshot: 2026-07-26. Keep exact star counts out of this file because they drift; use popularity only as a rough priority signal.

- end-4 dots-hyprland: https://github.com/end-4/dots-hyprland
  - Status: high-signal Quickshell plus Hyprland reference.
  - Kept locally: visual smoke screenshots, keybinding discoverability, notification/control/media polish goals, and Hyprland 0.55/Lua awareness.
  - Rejected here: full installer flow, AI/search extras, large theme engine, and distro-wide setup assumptions.
- Caelestia shell: https://github.com/caelestia-dots/shell
  - Status: high-signal Quickshell shell reference.
  - Kept locally: small IPC surface, shell-owned wallpaper/menu behavior, MPRIS/media ideas, hidden launcher entries, and config/state separation.
  - Rejected here: upstream CLI/runtime names, C++ plugin build path, broad token/theming system, and heavy dependency set.
- Noctalia shell: https://github.com/noctalia-dev/noctalia-shell
  - Status: high-signal Wayland shell reference.
  - Kept locally: desktop-shell boundary, compact control surfaces, notification history, brightness/audio/network/power modules, and clear package boundary thinking.
  - Rejected here: forked `noctalia-qs` runtime, plugin ecosystem, setup wizard, and shell-managed features better owned by Hyprland or normal apps.
- Omarchy: https://github.com/basecamp/omarchy
  - Status: high-signal Hyprland workflow reference, not a runtime dependency.
  - Kept locally: accepted key behavior, generated keybinding menu idea, local diagnostics/doctor direction, screen/share/menu shortcuts, and package/update hygiene ideas.
  - Rejected here: Omarchy-named binaries, distro-level refresh/update machinery, and assumptions that conflict with the default i3-compatible profile.
- cxOrz dotfiles-hyprland: https://github.com/cxOrz/dotfiles-hyprland
  - Status: lower-star but useful concrete ChromeOS-style layout reference.
  - Kept locally: compact control center shape, power/menu grouping, and tray/menu ergonomics.
  - Rejected here: rofi launcher, waybar/dunst ownership, hyprpaper ownership, Arch-only package assumptions, and greetd/session defaults.
- Aylur AGS/dotfiles ecosystem: https://github.com/Aylur/ags and https://aylur.github.io/ags/
  - Status: useful service/UI design reference, not part of the active stack.
  - Kept locally: listen-vs-poll thinking, notification/media/network service boundaries, launcher click-away behavior, and Alt-number launcher selection.
  - Rejected here: adding AGS/Astal as another shell runtime.
- surface-dots: https://github.com/snes19xx/surface-dots
  - Status: limited value for this Quickshell migration.
  - Kept locally: Hyprland-first login/session presentation checks.
  - Rejected here: monitor/surface-specific layout assumptions.
- ilyamiro nixos-configuration: https://github.com/ilyamiro/nixos-configuration
  - Status: useful for native Hyprland state ideas.
  - Kept locally: `hyprctl -j` state generation and event-triggered refresh.
  - Rejected here: a dedicated cache daemon until measured polling cost justifies it.
- ML4W dotfiles: https://github.com/mylinuxforwork/dotfiles
  - Status: popular Hyprland dotfiles reference, but broad distro/tooling scope.
  - Kept locally: doctor/setup validation direction and distro-aware package docs.
  - Rejected here: installer app, distro-wide OS assumptions, and broad app bundle.
- JaKooLit Hyprland-Dots: https://github.com/JaKooLit/Hyprland-Dots
  - Status: popular Hyprland install/dots reference, but not Quickshell-first.
  - Kept locally: installer-package tracking reminder and practical first-login checks.
  - Rejected here: rofi/waybar/swww/wallust stack and broad install scripts.

## Reference-derived implementation tasks

### Open UI/UX enhancement tasks

Review snapshot: 2026-07-28. Sources were local clones under `/tmp/wayland-ui-review`; refreshed clones include Caelestia, end-4, Noctalia, Omarchy, cxOrz, Aylur AGS, surface-dots, ilyamiro/nixos-configuration, ML4W, and JaKooLit. Refresh again before copying exact upstream code.

- [x] Add a launcher command mode.
  - Sources: Caelestia launcher actions/calculator/wallpaper modes, Omarchy menu app library.
  - Dependencies: keep the existing Quickshell launcher; add packages to homelab only if a calculator CLI is chosen.
  - Acceptance: `Win+D` can still launch apps, but a prefix can run local commands such as calculator, web search, wallpaper, and existing desktop helpers without rofi/dmenu.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `qs-menu-smoke launcher`, and one manual calculator/action launch.
  - Current behavior: `>` in the launcher opens command rows for web, YouTube, calculator, wallpaper, controls, settings, notifications, DND, media, and screenshot.
- [x] Add launcher favorite and hidden-app management.
  - Sources: Caelestia app favourites/hidden-app config, Omarchy launcher hide entries.
  - Dependencies: reuse Quickshell state JSON; do not add a second app database.
  - Acceptance: favorites rank above MRU/MFU, hidden apps disappear from the launcher, and both settings survive `qs-bar reload`.
  - Validation: `qs-menu-smoke launcher` plus manual favorite/hide/reload checks.
  - Current behavior: launcher rows expose favorite and hide controls; favorites rank above MRU/MFU and hidden entries are persisted in Quickshell state.
- [x] Add notification Do Not Disturb.
  - Sources: Caelestia DND toggle, Omarchy persisted notification DND and bar indicator.
  - Dependencies: reuse the current Quickshell notification owner and history model.
  - Acceptance: DND suppresses popup toasts but still records notifications in history, has a visible active state, and persists across `qs-bar reload`.
  - Validation: `desktop-notification-smoke --status`, `desktop-notification-smoke actions`, `qs-menu-smoke notifications controls`, and manual DND check.
  - Current behavior: DND persists in Quickshell state, suppresses toast popups, keeps notification history, and has bar/settings indicators.
- [x] Add volume, mic, and brightness OSD feedback.
  - Sources: Caelestia OSD module, Noctalia OSD overlay.
  - Dependencies: reuse current audio and brightness helpers; no new always-on daemon.
  - Acceptance: volume, mic mute, screen brightness, and keyboard brightness key changes show one compact overlay instead of notification spam.
  - Validation: `qmllint`, `qs-menu-smoke controls`, and manual XF86 key presses.
  - Current behavior: hardware volume, mic, screen brightness, and keyboard brightness bindings route through `desktop-osd` and Quickshell IPC.
- [x] Expand the calendar popup into a light day dashboard.
  - Sources: Caelestia dashboard calendar/weather/date-time widgets, Noctalia calendar/weather direction.
  - Dependencies: reuse `check-weather` and current todo source; no calendar account integration in this task.
  - Acceptance: calendar shows today, Lisbon time, configured extra timezones, weather summary, and the current todo/note block without becoming a full agenda client.
  - Validation: `qs-menu-smoke calendar` and manual clock/timezone sanity check.
  - Current behavior: calendar includes Lisbon clock, weather summary, and the existing todo block.
- [x] Add optional external monitor brightness controls.
  - Sources: Noctalia `ddcutil` optional dependency, Caelestia brightness service shape.
  - Dependencies: if `ddcutil` is used, track it in homelab install intent first.
  - Acceptance: laptop brightness stays on `brightnessctl`; external displays get separate controls only when `ddcutil detect` finds controllable monitors.
  - Validation: `desktop-package-audit`, `qs-menu-smoke controls`, and manual external-monitor brightness change.
  - Current behavior: `ddcutil` is installed and tracked in homelab; `external-brightness status` reports the current percent, `external-brightness set N` was validated by setting the current value back to itself, and Controls exposes the external display as a slider.
- [x] Add richer Bluetooth device controls.
  - Sources: Caelestia Bluetooth popout and device battery display.
  - Dependencies: reuse Quickshell Bluetooth service and existing controls popup.
  - Acceptance: controls can toggle Bluetooth, scan/discover, show connected device names, and show device battery where available.
  - Validation: `qmllint`, `qs-menu-smoke controls`, and manual Bluetooth toggle/scan check.
  - Current behavior: controls can toggle the adapter, start/stop discovery, and show connected device labels from the Quickshell Bluetooth service.
- [x] Add media now-playing detail.
  - Sources: Caelestia MPRIS dashboard/player selector/cover-progress ideas, Noctalia media widgets.
  - Dependencies: keep `audioctl` for local noise/music; use MPRIS/playerctl for normal players.
  - Acceptance: media popup shows the active MPRIS player, title/artist, play state, and the existing local noise/music controls without dead whitespace.
  - Validation: `audioctl self-test`, `qs-menu-smoke media`, and manual `audioctl restore` plus normal media player check.
  - Current behavior: `media-now-playing` reports the first MPRIS player; progress and player switching remain deferred until there is a real need.
- [x] Add privacy and session activity indicators.
  - Sources: Noctalia privacy/screencast direction, Caelestia service indicators.
  - Dependencies: reuse portal/audio state; avoid polling faster than current status refreshes.
  - Acceptance: bar indicates active microphone, camera, screen recording, and screen sharing when the local stack exposes that state; clicking opens the relevant screen/media controls.
  - Validation: `desktop-doctor`, `qs-menu-smoke screen media`, and manual Meet/share or recording check.
  - Current behavior: `desktop-privacy-status` reports mic capture from Pulse/PipeWire source outputs, camera use from open `/dev/video*` devices, and screen sharing from recorder/portal-style PipeWire nodes. Meet must be confirmed during a live call.
- [x] Add a compact Quickshell settings page for shell-owned toggles.
  - Sources: Caelestia Nexus settings pages, Noctalia configuration boundary.
  - Dependencies: only expose settings already backed by local state files.
  - Acceptance: one popup can change DND, launcher favorites visibility, tray native menus, bar hide/show, weather location, and UI density/font choice without editing files.
  - Validation: `qmllint`, `qs-menu-smoke controls`, and manual setting persistence after `qs-bar reload`.
  - Current behavior: `qs-bar settings` opens DND, native tray menu, bar visibility, density, weather location, launcher, notifications, and controls toggles.

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
  - Current behavior: existing center groups recent notifications by app, preserves notification actions, supports clear-one, clear-app, and clear-all, and `desktop-notification-smoke --status` verifies D-Bus action capability.
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

- [x] Reduce controls-hub keybindings to one real shortcut.
  - Current behavior: `Win+Ctrl+A` is the only intentional Controls shortcut; `Win+Ctrl+V` and `Win+Ctrl+W` are explicit no-op blockers, not duplicate menu shortcuts.
- [x] Fix `Win+V` behavior cleanly.
  - Current behavior: `Win+V` is terminal-aware paste; vertical split moved to `Win+Shift+V`; live Hyprland bindings verify `Win+Ctrl+V` and `Win+Ctrl+W` are harmless blockers.

- [x] Build a Quickshell power/session popup for `lock`, `logout`, `suspend`, `hibernate`, `reboot`, and `shutdown`.
  - Use native commands behind a local helper or IPC target: `loginctl lock-session`, `hyprctl dispatch exit`, `systemctl suspend`, `systemctl hibernate`, `systemctl reboot`, and `systemctl poweroff`.
  - Require confirmation for `logout`, `hibernate`, `reboot`, and `shutdown`.
  - Current behavior: the session popup asks for an in-menu confirmation before Hibernate, Reboot, Shutdown, or Exit Hyprland runs; Lock and Suspend stay one-click.
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
  - [x] Audio popup has per-stream mute/volume, active stream metadata, pavucontrol launch, noise toggle, music toggle, stop, right-click force-stop, and play/pause-all actions.
  - [x] Keep the top bar audio control icon-only; put details in the popup.
  - [x] Add screen brightness controls where hardware support exists.
  - [x] Add keyboard brightness controls where hardware support exists.
  - [x] Add an Awake idle/sleep inhibitor button backed by `systemd-inhibit`.
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
  - `Win+U` now uses a stable Ghostty popup title for the tmux popup session.

- [x] Verify browser WebGL through fresh wrapper-launched Chrome and Brave profiles.
  - Current behavior: `chrome-wayland` and `brave-wayland` both expose WebGL 2 through ANGLE on Intel Iris Xe under Hyprland. The wrappers still log a Vulkan compatibility warning, but WebGL works.
  - Decision: do not add `--use-gl=egl`, `--use-angle=opengl`, or `--use-gl=angle --use-angle=opengl`; all three broke WebGL in the smoke test.
- [x] Keep Chrome and Brave on conservative Wayland/PipeWire flags with Vulkan disabled unless `chrome://gpu` proves the Vulkan path is stable under Hyprland.
  - Current behavior: live Chrome and fresh Chrome/Brave test launches keep `--ozone-platform=wayland`, `--enable-native-notifications`, `UseOzonePlatform`, `WebRTCPipeWireCapturer`, `--disable-features=Vulkan`, and `--disable-vulkan`.
- [x] Review Electron apps for Wayland/PipeWire wrappers: Slack first, then 1Password, Obsidian, Zed-like editors, Discord/Zoom if installed.
  - Current behavior: Slack, 1Password, Discord, and Obsidian launch through local Wayland wrappers that unset inherited Nix/Mesa loader state and pass `--ozone-platform=wayland` plus `UseOzonePlatform,WebRTCPipeWireCapturer`.
  - Decision: Zed is already a native local app, and Zoom uses its own `/opt/zoom/ZoomLauncher`; no Electron flags are forced into either.

## 2026-07-28 Dashboard And Integration Tasks

Task source: this file is the canonical local queue for the Hyprland/Quickshell migration. It is fed by direct user requests, current local dotfiles behavior, smoke-test results, local reference clones under `/tmp/wayland-ui-review`, and official service docs when an external API is involved.

- [x] Highlight today and show uptime in the calendar popup.
  - Sources: current `check-time-panel`; Caelestia lock/system info shows uptime as compact status.
  - Acceptance: clock click shows Lisbon time, Unix/hex timestamp, uptime, and the current day visibly marked in the text calendar.
  - Validation: `check-time-panel` and `qs-menu-smoke calendar`.
- [x] Add signal-aware network status and on-demand public IP.
  - Sources: ilyamiro Quickshell/NMCLI Wi-Fi signal icon thresholds; current local `network-status`.
  - Acceptance: bar uses Wi-Fi strength icons; network popup shows local IP and public IP without polling public IP every bar refresh.
  - Validation: `network-status bar`, `NETWORK_STATUS_PUBLIC_IP=0 network-status details`, and `qs-menu-smoke network controls`.
- [x] Add a configurable shell primary color defaulting to Catppuccin Mocha lavender.
  - Sources: current Catppuccin palette in `shell.qml`; user preference for lavender as primary.
  - Acceptance: primary color is state-backed and used for notification attention, DND, muted audio, and selected notification borders.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`.
- [x] Add notification source-app focusing.
  - Sources: Quickshell notification API exposes actions and `desktopEntry`; Hyprland exposes clients through `hyprctl -j`.
  - Acceptance: expanded notification rows expose `Open`; clicking an already-expanded notification attempts to focus a matching Hyprland client by desktop entry, app name, class, or title.
  - Validation: `notification-focus-app --self-test`; send a desktop notification from an open app, open Notifications, expand it, then use `Open`.
- [x] Add a launcher hidden-app smoke test.
  - Sources: Caelestia app info page exposes favorite/hidden launcher settings; local launcher already persists `hiddenAppIds` in Quickshell state.
  - Acceptance: `qs-menu-smoke launcher-hidden` asks Quickshell to hide one visible desktop entry in memory, proves it disappears, restores the override, and reports pass/fail without editing persisted launcher settings.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `bash -n desktop/bin/qs-menu-smoke`, `home -y`, `qs-bar reload`, `qs-menu-smoke launcher-hidden`, and `qs-menu-smoke launcher`.

- [x] Polish calendar popup task/weather presentation.
  - Sources: current `check-todo-panel`, `check-time-panel`, `check-weather`, user preference for Palmela weather and primary-color today marker.
  - Acceptance: time popup shows Taskwarrior ready tasks without broken leading indentation, highlights today in a native QML calendar grid with the configured primary color, and shows Palmela weather with today/tomorrow min-max temperatures.
  - Validation: `check-todo-panel`, `check-time-panel`, `WEATHER_LOCATION="Palmela, Portugal" check-weather panel`, `qmllint`, and `qs-menu-smoke calendar`.
- [ ] Design Pomodoro plus timewarrior integration.
  - Sources: current calendar/time menu, Taskwarrior todo block, possible `timew` tracking state.
  - Acceptance: design a minimal Pomodoro surface for the time menu with start/pause/stop, current focus label, optional Taskwarrior task link, and optional timewarrior interval start/stop without storing task notes in QML state.
  - Validation: design note with commands and no-secret state boundary before implementation.
- [ ] Wire a future board-backed personal dashboard into Quickshell.
  - Sources: rush `board/docs/personal-dashboards.md`, current Quickshell calendar/controls panels, board `personal.today`/`personal.money` surfaces once implemented.
  - Acceptance: Quickshell renders Today, Money, Health, and Habits tabs from board state only; buttons call `board action`; QML does not run hledger, fetch prices, parse health exports, or store raw private data.
  - Validation: `qs-menu-smoke personal-dashboard`, `desktop-doctor`, and `board render text personal.today`.

- [x] Make the Quickshell clipboard picker a true popup.
  - Sources: current Quickshell clipboard picker, launcher popup behavior, user report that clipboard should be popup-like instead of a normal window.
  - Current behavior: `qs-bar clipboard` toggles a centered 720x500 floating Quickshell picker, uses the same Hyprland float/center rule shape as launcher/web search, takes focus immediately, and closes through Escape, focus-grab clear, or repeated toggle.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `bash -n desktop/bin/qs-menu-smoke desktop/bin/hypr-session desktop/bin/qs-bar`, `qs-menu-smoke clipboard-toggle clipboard`, and `desktop-doctor`.
- [x] Integrate secret-aware clipboard handling with gopass/GPaste.
  - Sources: local `gopass-clip-copy`, `gopass-clip-clear`, `history-secrets`, `passmenu`, local gopass/GPaste command surface, and the current Quickshell clipboard picker.
  - Constraint: keep decrypted values out of argv, logs, QML state, and normal clipboard history by default.
  - Current behavior: `passmenu` opens a Quickshell password picker again; QML stores only entry names, and selection delegates copy/type work to `passmenu-action`. Copy mode uses `gopass show -c` with tracked `GOPASS_CLIPBOARD_COPY_CMD`/`GOPASS_CLIPBOARD_CLEAR_CMD` defaults, so gopass owns timeout/clear behavior through repo-managed hooks. `gopass-clip-copy` is stdin-only and does not use local `gpaste-client add-password`, because that command requires the decrypted password in argv on this machine; unsafe `copyq` secret copy is refused. Quickshell clipboard history filters obvious secret-like rows from the normal picker.
  - Validation: `passmenu-action --self-test`, fake-backend `passmenu --name`, fake-backend `passmenu --user`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `bash -n desktop/bin/passmenu desktop/bin/passmenu-action desktop/bin/gopass-clip-copy desktop/bin/gopass-clip-clear desktop/bin/desktop-doctor desktop/bin/desktop-accept desktop/bin/hypr-session`, `qs-menu-smoke`, and `desktop-doctor`.
- [x] Add a redacted work inbox status helper.
  - Sources: Slack Conversations API, GitHub search through `gh api`, Linear notifications GraphQL, and existing cache patterns.
  - Current behavior: `work-inbox-status` prints cached JSON for Slack unread counts, GitHub PR review requests, and Linear notification counts. Missing credentials are quiet unavailable states; tokens and message text never enter stdout or curl argv.
  - Validation: `work-inbox-status --self-test`, `work-inbox-status --no-network`, and `desktop-doctor`.
- [x] Build a small unread-work Quickshell dashboard from `work-inbox-status`.
  - Current behavior: `qs-bar work-inbox` opens a right-side Quickshell popup with Slack unread/mentions, GitHub review requests, and Linear notification counts from the helper. Controls also has a Work button.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `qs-menu-smoke work-inbox`, and `desktop-doctor`.
- [ ] Add future Google Calendar agenda integration.
  - Source: Google Calendar Events `list` API supports calendar event listing and sync tokens.
  - Acceptance: calendar popup can show the next events through a helper that uses local credentials and caches sync state; no credentials enter QML.
  - Validation: helper lists redacted upcoming event metadata and calendar popup handles offline/auth-failure states.
- [ ] Redesign meeting/privacy awareness around DND.
  - Sources: AGS/Astal audio/video service model, Noctalia privacy/recording indicators, current `desktop-privacy-status`.
  - Acceptance: mic/camera/screenshare indicators become a single DND-aware meeting state with clear active/inactive/muted colors, quieter bar output, and detailed state only in the controls/privacy popup.
  - Validation: `desktop-privacy-status status`, Meet mic/camera/share manual test, and `qs-menu-smoke controls screen`.
- [ ] Add app-open deep links for notification producers where generic focusing is not enough.
  - Sources: notification `desktopEntry` metadata, app-specific desktop files, Hyprland client matching.
  - Acceptance: Slack/Chrome/Linear-style notifications can open or focus the useful app/window when a default action is absent.
  - Validation: one notification from each supported app focuses the right window or reports unsupported.


### Execution Plan For Open Dashboard Tasks

Do these in this order; each task should leave one small validation command behind. Keep all secrets in helpers, never in QML state.

1. Launcher hidden-app proof. Done.
   - Task: `qs-menu-smoke launcher-hidden` calls Quickshell IPC to hide one visible desktop entry with an in-memory override, verifies it is absent from launcher results, then clears the override.
   - Depends on: existing `hiddenAppIds` filter path and launcher rebuild.
   - Validation: `qs-menu-smoke launcher-hidden` plus normal `qs-menu-smoke launcher`.
   - Result: passed with desktop entry `1password`; persisted `hiddenAppIds` is not edited.
2. Notification open/focus hardening. Done.
   - Task: `notification-focus-app --self-test` now exercises fake `hyprctl clients -j` input and verifies Chrome, Slack, and WezTerm desktop-entry/app-name matching.
   - Depends on: current `notification-focus-app` helper.
   - Validation: `notification-focus-app --self-test`, `desktop-notification-smoke actions`, manual Slack/Chrome notification focus.
   - Result: generic matching now normalizes reverse-DNS desktop IDs; no unsupported app-specific behavior found in the local test fixture.
3. Clipboard popup parity. Done.
   - Task: make `qs-bar clipboard` use the same popup/focus-grab behavior as the launcher instead of presenting as a normal side/tiled window.
   - Depends on: current Quickshell clipboard picker and `cliphist-menu` data path.
   - Validation: `qs-menu-smoke clipboard-toggle clipboard` and `desktop-doctor`.
   - Result: clipboard now toggles through Quickshell IPC, is centered/floating by Hyprland title rule, and exposes a smoke-test visible state.
4. Secret-safe clipboard and gopass integration. Done.
   - Task: audit active password copy paths, keep decrypted values out of QML, and make Quickshell clipboard hide likely secret rows from normal `cliphist`.
   - Depends on: `passmenu`, `passmenu-action`, `gopass-clip-copy`, `gopass-clip-clear`, and the local GPaste/gopass command surface.
   - Validation: `passmenu-action --self-test`, fake-backend `passmenu --name`, fake-backend `passmenu --user`, `qs-menu-smoke`, and `desktop-doctor`.
   - Result: `passmenu` has a Quickshell popup target again; copy/type actions run in a helper, not QML; gopass copy uses repo-managed clipboard hook defaults; local GPaste password-entry mode and copyq secret copy are intentionally not used because they require password argv.
5. Work inbox helper first, dashboard second. Helper done.
   - Task: `work-inbox-status` returns redacted cached JSON counts for Slack unread, GitHub PR review requests, and Linear notifications.
   - Sources: Slack Conversations API, GitHub search through `gh api`, Linear notifications GraphQL, and local cache patterns.
   - Validation: `work-inbox-status --self-test`, `work-inbox-status --no-network`, and `desktop-doctor`.
   - Result: `qs-bar work-inbox` now opens a Quickshell popup fed by this helper; the Controls menu exposes it as Work. Missing credentials render quiet unavailable rows.
6. Meeting and DND awareness.
   - Task: collapse mic/camera/screenshare into one DND-aware meeting indicator and move details into controls/privacy popup.
   - Sources: current `desktop-privacy-status`, AGS/Astal audio/video service model, Noctalia privacy indicators.
   - Depends on: PipeWire source outputs, `/dev/video*` holders, portal screen-share state, DND state.
   - Validation: `desktop-privacy-status status`, `qs-menu-smoke controls screen`, manual Google Meet mic/camera/share check.
   - Stop if: Chrome/Meet does not expose enough metadata to distinguish call state from generic media capture; show capture state only.
7. Pomodoro plus timewarrior design.
   - Task: write the minimal design for a time-menu Pomodoro timer with optional Taskwarrior/timewarrior links before implementation.
   - Depends on: current calendar popup and local `task`/`timew` availability.
   - Validation: design note documents commands, state files, and no-secret QML boundary.
8. Calendar agenda integration.
   - Task: add a helper for cached Google Calendar event summaries, then feed the existing calendar popup.
   - Depends on: local credential storage decision and no-secret QML boundary.
   - Validation: helper prints redacted next-event metadata; calendar popup handles offline/auth failure.
   - Stop if: credentials are not configured; keep current local `khal`/time dashboard.
9. Visual consistency pass.
   - Task: normalize panel spacing, action row size, and empty states across launcher, clipboard, network, notifications, calendar, media, and controls using current local components.
   - Sources: Noctalia compact control-center layout, Caelestia settings/actions, cxOrz quick settings, end-4 smoke/utility polish.
   - Depends on: screenshot smoke visibility.
   - Validation: full `qs-menu-smoke`, inspect contact sheet, `desktop-doctor`.

## Automation helpers

- `desktop-accept` applies dotfiles, reloads Quickshell, runs Hyprland smoke, runs full Quickshell menu smoke, and finishes with `desktop-doctor`.
- `desktop-startup-report` prints Hyprland startup commands, autostart desktop files, running user services, and the current Quickshell instance.

## Notes

- `default` is the i3-compatible profile. There is intentionally no separate `i3` profile.
- Quickshell owns bar, launcher, tray, wallpaper, controls, calendar, notification history, network panel, lock IPC, and exit confirmation; controls also acts as the all-menus hub. `board` is the tracked local status renderer for Quickshell and tmux surfaces.
- Both profiles use the local lightweight Quickshell shell. The `omarchy` profile does not install or call upstream runtime binaries.
- Adapted reference patterns already landed locally: Caelestia-like session actions behind local commands, end-4-like `Super+/` keybinding help and cliphist watcher refresh, Noctalia-like compact popup/control surfaces, and cxOrz-like cliphist as backend plumbing.
- Rust system-metrics helper is intentionally not active work. The future note lives in `wiki/main/resources/dev/desktop.md`; build it only if measured Quickshell status polling cost becomes a real problem.
