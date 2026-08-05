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

- [x] `Win+Space` opens the local Quickshell launcher through `qs-bar launcher`.
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
- [x] `desktop/tools/desktop-doctor` wraps the live Wayland smoke check with current profile, Quickshell status, board status, picker helper status, clipboard helper status, audio state, audioctl pause/resume/status regression checks, screenshot helper status, wallpaper helper status, screen-record status, notification-smoke readiness, and static browser wrapper flag checks.
- [x] `desktop/tools/desktop-package-audit` verifies active Wayland helper package intent, including local `board`, is tracked in the sibling homelab install list, and `desktop/tools/desktop-doctor` runs it.
- [x] `desktop/tools/qs-menu-smoke` opens, captures, closes, and checks Quickshell launcher/control/media/notification/calendar/wallpaper/screen/keybinding/clipboard/websearch/network/tray/power/power-confirm menu screenshots plus `contact.png` for visual regression checks; `desktop/tools/desktop-doctor` now fails when the latest smoke run predates live Quickshell QML.

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
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke launcher`, and one manual calculator/action launch.
  - Current behavior: `>` in the launcher opens command rows for web, YouTube, calculator, wallpaper, controls, settings, notifications, DND, media, and screenshot.
- [x] Add launcher favorite and hidden-app management.
  - Sources: Caelestia app favourites/hidden-app config, Omarchy launcher hide entries.
  - Dependencies: reuse Quickshell state JSON; do not add a second app database.
  - Acceptance: favorites rank above MRU/MFU, hidden apps disappear from the launcher, and both settings survive `qs-bar reload`.
  - Validation: `desktop/tools/qs-menu-smoke launcher` plus manual favorite/hide/reload checks.
  - Current behavior: launcher rows expose favorite and hide controls; favorites rank above MRU/MFU and hidden entries are persisted in Quickshell state.
- [x] Add notification Do Not Disturb.
  - Sources: Caelestia DND toggle, Omarchy persisted notification DND and bar indicator.
  - Dependencies: reuse the current Quickshell notification owner and history model.
  - Acceptance: DND suppresses popup toasts but still records notifications in history, has a visible active state, and persists across `qs-bar reload`.
  - Validation: `desktop/tools/desktop-notification-smoke --status`, `desktop/tools/desktop-notification-smoke actions`, `desktop/tools/qs-menu-smoke notifications controls`, and manual DND check.
  - Current behavior: DND persists in Quickshell state, suppresses toast popups, keeps notification history, and has bar/settings indicators.
- [x] Add volume, mic, and brightness OSD feedback.
  - Sources: Caelestia OSD module, Noctalia OSD overlay.
  - Dependencies: reuse current audio and brightness helpers; no new always-on daemon.
  - Acceptance: volume, mic mute, screen brightness, and keyboard brightness key changes show one compact overlay instead of notification spam.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls`, and manual XF86 key presses.
  - Current behavior: hardware volume, mic, screen brightness, and keyboard brightness bindings route through `desktop-osd` and Quickshell IPC.
- [x] Expand the calendar popup into a light day dashboard.
  - Sources: Caelestia dashboard calendar/weather/date-time widgets, Noctalia calendar/weather direction.
  - Dependencies: reuse `check-weather` and current todo source; no calendar account integration in this task.
  - Acceptance: calendar shows today, Lisbon time, configured extra timezones, weather summary, and the current todo/note block without becoming a full agenda client.
  - Validation: `desktop/tools/qs-menu-smoke calendar` and manual clock/timezone sanity check.
  - Current behavior: calendar includes Lisbon clock, weather summary, and the existing todo block.
- [x] Add optional external monitor brightness controls.
  - Sources: Noctalia `ddcutil` optional dependency, Caelestia brightness service shape.
  - Dependencies: if `ddcutil` is used, track it in homelab install intent first.
  - Acceptance: laptop brightness stays on `brightnessctl`; external displays get separate controls only when `ddcutil detect` finds controllable monitors.
  - Validation: `desktop/tools/desktop-package-audit`, `desktop/tools/qs-menu-smoke controls`, and manual external-monitor brightness change.
  - Current behavior: `ddcutil` is installed and tracked in homelab; `external-brightness status` reports the current percent, `external-brightness set N` was validated by setting the current value back to itself, and Controls exposes the external display as a slider.
- [x] Add richer Bluetooth device controls.
  - Sources: Caelestia Bluetooth popout and device battery display.
  - Dependencies: reuse Quickshell Bluetooth service and existing controls popup.
  - Acceptance: controls can toggle Bluetooth, scan/discover, show connected device names, and show device battery where available.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls`, and manual Bluetooth toggle/scan check.
  - Current behavior: controls can toggle the adapter, start/stop discovery, and show connected device labels from the Quickshell Bluetooth service.
- [x] Add media now-playing detail.
  - Sources: Caelestia MPRIS dashboard/player selector/cover-progress ideas, Noctalia media widgets.
  - Dependencies: keep `audioctl` for local noise/music; use MPRIS/playerctl for normal players.
  - Acceptance: media popup shows the active MPRIS player, title/artist, play state, and the existing local noise/music controls without dead whitespace.
  - Validation: `audioctl self-test`, `desktop/tools/qs-menu-smoke media`, and manual `audioctl restore` plus normal media player check.
  - Current behavior: `media-now-playing` reports the first MPRIS player; progress and player switching remain deferred until there is a real need.
- [x] Add privacy and session activity indicators.
  - Sources: Noctalia privacy/screencast direction, Caelestia service indicators.
  - Dependencies: reuse portal/audio state; avoid polling faster than current status refreshes.
  - Acceptance: bar indicates active microphone, camera, screen recording, and screen sharing when the local stack exposes that state; clicking opens the relevant screen/media controls.
  - Validation: `desktop/tools/desktop-doctor`, `desktop/tools/qs-menu-smoke screen media`, and manual Meet/share or recording check.
  - Current behavior: `desktop-privacy-status` reports mic capture from Pulse/PipeWire source outputs, camera use from open `/dev/video*` devices, and screen sharing from recorder/portal-style PipeWire nodes. Meet must be confirmed during a live call.
- [x] Add a compact Quickshell settings page for shell-owned toggles.
  - Sources: Caelestia Nexus settings pages, Noctalia configuration boundary.
  - Dependencies: only expose settings already backed by local state files.
  - Acceptance: one popup can change DND, launcher favorites visibility, tray native menus, bar hide/show, weather location, and UI density/font choice without editing files.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls`, and manual setting persistence after `qs-bar reload`.
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
  - Current behavior: existing center groups recent notifications by app, preserves notification actions, supports clear-one, clear-app, and clear-all, and `desktop/tools/desktop-notification-smoke --status` verifies D-Bus action capability.
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
  - Validation: `check-time-panel` and `desktop/tools/qs-menu-smoke calendar`.
- [x] Add signal-aware network status and on-demand public IP.
  - Sources: ilyamiro Quickshell/NMCLI Wi-Fi signal icon thresholds; current local `network-status`.
  - Acceptance: bar uses Wi-Fi strength icons; network popup shows local IP and public IP without polling public IP every bar refresh.
  - Validation: `network-status bar`, `NETWORK_STATUS_PUBLIC_IP=0 network-status details`, and `desktop/tools/qs-menu-smoke network controls`.
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
  - Acceptance: `desktop/tools/qs-menu-smoke launcher-hidden` asks Quickshell to hide one visible desktop entry in memory, proves it disappears, restores the override, and reports pass/fail without editing persisted launcher settings.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `bash -n desktop/tools/qs-menu-smoke`, `home -y`, `qs-bar reload`, `desktop/tools/qs-menu-smoke launcher-hidden`, and `desktop/tools/qs-menu-smoke launcher`.

- [x] Polish calendar popup task/weather presentation.
  - Sources: current `check-todo-panel`, `check-time-panel`, `check-weather`, user preference for Palmela weather and primary-color today marker.
  - Acceptance: time popup shows Taskwarrior ready tasks without broken leading indentation, highlights today in a native QML calendar grid with the configured primary color, and shows Palmela weather with today/tomorrow min-max temperatures.
  - Validation: `check-todo-panel`, `check-time-panel`, `WEATHER_LOCATION="Palmela, Portugal" check-weather panel`, `qmllint`, and `desktop/tools/qs-menu-smoke calendar`.
- [x] Design Pomodoro plus timewarrior integration.
  - Sources: current calendar/time menu, Taskwarrior todo block, possible `timew` tracking state.
  - Current behavior: `docs/desktop/pomodoro-timewarrior.md` defines a future `pomodoroctl` helper boundary, JSON shape, state file, Timewarrior ownership rules, and Quickshell calendar surface.
  - Validation: `test -s docs/desktop/pomodoro-timewarrior.md`.
- [x] Implement `pomodoroctl` before adding QML controls.
  - Acceptance: helper supports `status`, `start`, `pause`, `resume`, `stop`, `break`, and `self-test`; it never stops unrelated Timewarrior intervals.
  - Current behavior: `desktop/bin/pomodoroctl` stores local timer state under Quickshell state, prints redacted JSON for QML, uses Timewarrior only when available and idle, and stops Timewarrior only for helper-owned `pomodoro` intervals.
  - Validation: `pomodoroctl self-test` and `pomodoroctl status`.
- [x] Wire `pomodoroctl` into the calendar popup.
  - Acceptance: calendar popup shows the current Pomodoro mode, remaining time, focus label, and start/pause/resume/stop/break controls backed only by `pomodoroctl`.
  - Current behavior: the calendar popup refreshes `pomodoroctl status`, shows mode, remaining time, label, Timewarrior state, and exposes Start/Pause/Resume/Stop/5m/15m controls.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke calendar`, and `desktop/tools/desktop-doctor`.
- [x] Add a board-rendered personal dashboard shell to Quickshell.
  - Sources: rush `board/docs/personal-dashboards.md`, current Quickshell controls/work-inbox panel patterns, and installed board `render text personal.*` surfaces.
  - Current behavior: `qs-bar personal-dashboard` opens a right-side Quickshell popup with Today, Money, Health, and Habits tabs rendered only from `board --config ~/.config/board/board.toml render text`; Controls exposes it as Dash.
  - Validation: `board render text personal.today`, `qmllint`, `desktop/tools/qs-menu-smoke personal-dashboard`, and `desktop/tools/desktop-doctor`.
- [x] Add board actions to the personal dashboard once board exposes an action CLI.
  - Current behavior: `board action` is implemented in rush with nested TOML action definitions, no-shell argv execution, `--dry-run`, and `--yes` for confirmed actions. The Personal dashboard exposes a `Fresh` button that calls `board --config ~/.config/board/board.toml action personal.refresh`; QML still renders only `board render text` output and delegates action execution to `board`.
  - Validation: `cargo test -p board`, `cargo build -p board --release`, install to `~/bin/board`, `board action --help`, `board --config desktop/.config/board/board.toml action --dry-run personal.refresh`, `board --config ~/.config/board/board.toml action personal.refresh`, `qmllint ...`, `home -y`, `qs-bar reload`, `desktop/tools/qs-menu-smoke personal-dashboard`, and `desktop/tools/desktop-doctor`.

- [x] Make the Quickshell clipboard picker a true popup.
  - Sources: current Quickshell clipboard picker, launcher popup behavior, user report that clipboard should be popup-like instead of a normal window.
  - Current behavior: `qs-bar clipboard` toggles a centered 720x500 floating Quickshell picker, uses the same Hyprland float/center rule shape as launcher/web search, takes focus immediately, and closes through Escape, focus-grab clear, or repeated toggle.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `bash -n desktop/tools/qs-menu-smoke desktop/bin/hypr-session desktop/bin/qs-bar`, `desktop/tools/qs-menu-smoke clipboard-toggle clipboard`, and `desktop/tools/desktop-doctor`.
- [x] Integrate secret-aware clipboard handling with gopass/Wayland.
  - Sources: local `gopass-clip-copy`, `gopass-clip-clear`, `history-secrets`, `passmenu`, local gopass/Wayland clipboard command surface, and the current Quickshell clipboard picker.
  - Constraint: keep decrypted values out of argv, logs, QML state, and normal clipboard history by default.
  - Current behavior: `passmenu` opens a Quickshell password picker again; QML stores only entry names, and selection delegates copy/type work to `passmenu-action`. Copy mode uses `gopass show -c` with tracked `GOPASS_CLIPBOARD_COPY_CMD`/`GOPASS_CLIPBOARD_CLEAR_CMD` defaults. `gopass-clip-copy` is stdin-only and leaves `cliphist` running; `gopass-clip-clear` is temporarily a no-op while debugging Wayland paste regressions. `cliphist-menu watch` mirrors normal text clipboard changes into the primary selection for middle-click paste. GPaste remains disabled because its daemon can take stale Wayland clipboard ownership. Password copies may enter normal clipboard history until secret cleanup is re-enabled.
  - Validation: `passmenu-action --self-test`, fake-backend `passmenu --name`, fake-backend `passmenu --user`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `bash -n desktop/bin/passmenu desktop/bin/passmenu-action desktop/bin/gopass-clip-copy desktop/bin/gopass-clip-clear desktop/tools/desktop-doctor desktop/tools/desktop-accept desktop/bin/hypr-session`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
- [x] Add a redacted work inbox status helper.
  - Sources: Slack Conversations API, GitHub search through `gh api`, Linear notifications GraphQL, and existing cache patterns.
  - Current behavior: `work-inbox-status` prints cached JSON for Slack unread counts, GitHub PR review requests, and Linear notification counts. Missing credentials are quiet unavailable states; tokens and message text never enter stdout or curl argv.
  - Validation: `work-inbox-status --self-test`, `work-inbox-status --no-network`, and `desktop/tools/desktop-doctor`.
- [x] Build a small unread-work Quickshell dashboard from `work-inbox-status`.
  - Current behavior: `qs-bar work-inbox` opens a right-side Quickshell popup with Slack unread/mentions, GitHub review requests, and Linear notification counts from the helper. Controls also has a Work button.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke work-inbox`, and `desktop/tools/desktop-doctor`.
- [x] Add local calendar agenda integration.
  - Source: existing `khal` local calendar cache; future Google/CalDAV sync stays outside Quickshell.
  - Current behavior: `calendar-agenda-status` renders upcoming local agenda text from `khal list today 7d --notstarted`; the calendar popup shows it in a dedicated Agenda block and refreshes through the helper.
  - Validation: `calendar-agenda-status self-test`, `qmllint`, `desktop/tools/qs-menu-smoke calendar`, and `desktop/tools/desktop-doctor`.
- [x] Add a Google Calendar sync boundary outside Quickshell.
  - Current blocker: no tracked `gcalcli` or `vdirsyncer` setup is present; Quickshell only consumes local khal output.
  - Acceptance: external sync populates the local khal calendar cache without credentials entering QML or shell command argv.
  - Validation: `khal list today 7d --notstarted` shows synced events and `calendar-agenda-status` handles auth/offline states.
  - Current behavior: `calendar-sync-status` records the boundary: this machine is local-khal-only until an external sync tool is installed/configured outside Quickshell. Quickshell and QML still never own calendar credentials.
- [x] Redesign meeting/privacy awareness around DND.
  - Current behavior: the bar uses one DND-aware privacy indicator for mic, camera, screen share/recording, and DND; left click opens Screen details and right click toggles DND. Controls includes a compact privacy state block with refresh/details actions.
  - Constraint: this detects capture state, not a guaranteed Google Meet meeting identity, because Chrome/portal state does not expose enough app-specific call metadata locally.
  - Validation: `desktop-privacy-status status`, `desktop-privacy-status self-test`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke controls screen`, and `desktop/tools/desktop-doctor`.
- [x] Add app-open deep links for notification producers where generic focusing is not enough.
  - Sources: notification `desktopEntry` metadata, app-specific desktop files, Hyprland client matching.
  - Current behavior: notification `Open` first focuses a matching Hyprland window; when none exists it launches Slack, Chrome, Brave, Linear inbox, Discord, Obsidian, 1Password, or falls back to `gtk-launch` for known desktop entries.
  - Validation: `notification-focus-app --self-test`, one notification from each supported app focuses the right window or opens the wrapper.


### Execution Plan For Open Dashboard Tasks

Do these in this order; each task should leave one small validation command behind. Keep all secrets in helpers, never in QML state.

1. Launcher hidden-app proof. Done.
   - Task: `desktop/tools/qs-menu-smoke launcher-hidden` calls Quickshell IPC to hide one visible desktop entry with an in-memory override, verifies it is absent from launcher results, then clears the override.
   - Depends on: existing `hiddenAppIds` filter path and launcher rebuild.
   - Validation: `desktop/tools/qs-menu-smoke launcher-hidden` plus normal `desktop/tools/qs-menu-smoke launcher`.
   - Result: passed with desktop entry `1password`; persisted `hiddenAppIds` is not edited.
2. Notification open/focus hardening. Done.
   - Task: `notification-focus-app --self-test` now exercises fake `hyprctl clients -j` input and verifies Chrome, Slack, and WezTerm desktop-entry/app-name matching.
   - Depends on: current `notification-focus-app` helper.
   - Validation: `notification-focus-app --self-test`, `desktop/tools/desktop-notification-smoke actions`, manual Slack/Chrome notification focus.
   - Result: generic matching now normalizes reverse-DNS desktop IDs; no unsupported app-specific behavior found in the local test fixture.
3. Clipboard popup parity. Done.
   - Task: make `qs-bar clipboard` use the same popup/focus-grab behavior as the launcher instead of presenting as a normal side/tiled window.
   - Depends on: current Quickshell clipboard picker and `cliphist-menu` data path.
   - Validation: `desktop/tools/qs-menu-smoke clipboard-toggle clipboard` and `desktop/tools/desktop-doctor`.
   - Result: clipboard now toggles through Quickshell IPC, is centered/floating by Hyprland title rule, and exposes a smoke-test visible state.
4. Secret-safe clipboard and gopass integration. Done.
   - Task: audit active password copy paths, keep decrypted values out of QML, and make Quickshell clipboard hide likely secret rows from normal `cliphist`.
   - Depends on: `passmenu`, `passmenu-action`, `gopass-clip-copy`, `gopass-clip-clear`, and the local GPaste/gopass command surface.
   - Validation: `passmenu-action --self-test`, fake-backend `passmenu --name`, fake-backend `passmenu --user`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
   - Result: `passmenu` has a Quickshell popup target again; copy/type actions run in a helper, not QML; gopass copy uses repo-managed clipboard hook defaults; local GPaste password-entry mode and copyq secret copy are intentionally not used because they require password argv.
5. Work inbox helper first, dashboard second. Helper done.
   - Task: `work-inbox-status` returns redacted cached JSON counts for Slack unread, GitHub PR review requests, and Linear notifications.
   - Sources: Slack Conversations API, GitHub search through `gh api`, Linear notifications GraphQL, and local cache patterns.
   - Validation: `work-inbox-status --self-test`, `work-inbox-status --no-network`, and `desktop/tools/desktop-doctor`.
   - Result: `qs-bar work-inbox` now opens a Quickshell popup fed by this helper; the Controls menu exposes it as Work. Missing credentials render quiet unavailable rows.
6. Meeting and DND awareness. Done.
   - Task: collapse mic/camera/screenshare into one DND-aware meeting indicator and move details into controls/privacy popup.
   - Result: capture indicators and DND are shown as one bar item; Controls and Screen show the detailed helper output. This intentionally reports capture state only, not confirmed Meet identity.
   - Validation: `desktop-privacy-status self-test`, `qmllint`, `desktop/tools/qs-menu-smoke controls screen`, and `desktop/tools/desktop-doctor`.
7. Pomodoro plus timewarrior design. Done.
   - Task: write the minimal design for a time-menu Pomodoro timer with optional Taskwarrior/timewarrior links before implementation.
   - Result: `docs/desktop/pomodoro-timewarrior.md` documents commands, state files, Timewarrior ownership, JSON output, and no-secret QML boundary.
   - Result: `desktop/bin/pomodoroctl` implements status/start/pause/resume/stop/break/self-test and is covered by `desktop/tools/desktop-doctor`.
   - Result: the calendar popup renders `pomodoroctl` status and calls the helper for all timer actions.
   - Next: calendar agenda integration or visual consistency pass.
8. Personal dashboard shell. Done.
   - Task: add a Quickshell popup that renders board-owned Today, Money, Health, and Habits surfaces without collecting private data in QML.
   - Result: `qs-bar personal-dashboard` toggles the popup, Controls exposes Dash, and smoke tests capture the panel.
   - Blocked next: board action buttons wait for an installed `board action` subcommand.
9. Calendar agenda integration. Done locally.
   - Task: add a helper for cached calendar summaries, then feed the existing calendar popup.
   - Result: `calendar-agenda-status` renders upcoming events from the local khal cache, and the calendar popup has a dedicated Agenda section.
   - Blocked next: Google account sync credentials/tooling are intentionally outside Quickshell and not configured here.
10. Visual consistency pass. Done first pass.
   - Task: normalize panel spacing, action row size, and empty states across launcher, clipboard, network, notifications, calendar, media, and controls using current local components.
   - Sources: Noctalia compact control-center layout, Caelestia settings/actions, cxOrz quick settings, end-4 smoke/utility polish.
   - Result: shared action buttons now keep a stable height and elide long labels instead of overflowing; the media popup width matches the other right-side dashboards; Controls menu rows no longer cram six actions into one row.
   - Follow-up: right-side Quickshell menus now use a shared 640px width, crowded panels use 560px height, compact panels use 360px height, calendar keeps a taller 720px surface, Work Inbox uses 420px, Personal uses 460px, Media uses the same medium height as Work Inbox, and default action buttons are wider so labels do not collapse to two letters, and menu smoke crops now match the wider right-side panels.
   - Follow-up: current screenshot pass trims the Session menu to a compact width, makes Exit Hyprland secondary, gives Controls enough height for its bottom rows, expands Controls menu buttons to readable cells, makes Privacy action buttons icon-only, and tones down Media stream mute buttons.
   - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke controls media notifications clipboard network calendar`, and `desktop/tools/desktop-doctor`.

## Automation helpers

- `desktop/tools/desktop-accept` applies dotfiles, reloads Quickshell, runs Hyprland smoke, runs full Quickshell menu smoke, and finishes with `desktop/tools/desktop-doctor`.
- `desktop-startup-report` prints Hyprland startup commands, autostart desktop files, running user services, and the current Quickshell instance.

## Notes

- `default` is the i3-compatible profile. There is intentionally no separate `i3` profile.
- Quickshell owns bar, launcher, tray, wallpaper, controls, calendar, notification history, network panel, lock IPC, and exit confirmation; controls also acts as the all-menus hub. `board` is the tracked local status renderer for Quickshell and tmux surfaces.
- Both profiles use the local lightweight Quickshell shell. The `omarchy` profile does not install or call upstream runtime binaries.
- Adapted reference patterns already landed locally: Caelestia-like session actions behind local commands, end-4-like `Super+/` keybinding help and cliphist watcher refresh, Noctalia-like compact popup/control surfaces, and cxOrz-like cliphist as backend plumbing.
- Rust system-metrics helper is intentionally not active work. The future note lives in `wiki/main/resources/dev/desktop.md`; build it only if measured Quickshell status polling cost becomes a real problem.

## Open polish and simplification tasks

Review snapshot: 2026-08-03. Sources: local reference clones for Caelestia, end-4, Noctalia, Omarchy, cxOrz, surface-dots, ilyamiro/nixos-configuration, Aylur AGS, ML4W, and JaKooLit. Priority favors code repetition, simple config, and keeping this shell maintainable over adding new runtime layers.

### Config and repetition priority backlog

- [x] P0: Replace repeated Quickshell literals with a tiny theme token map.
  - Sources: cxOrz `Theme.qml`, surface-dots `theme.js`, Caelestia token/state split.
  - Acceptance: repeated font family, font sizes, radii, spacing, panel widths/heights, and Catppuccin colors are read from `ShellTheme.qml`/`ShellConfig.qml`; local overrides remain only where a value is genuinely different.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "spacing: (12|10|8|7|6|5|4|2)|implicitHeight: (36|52)|actionRow\.implicitWidth  18|radius: isGroup \? 0 : 5|anchors\.margins: 8" desktop/.config/quickshell/marcelof/Shell*.qml`.
  - Current behavior: `ShellTheme.qml` now owns common spacing, padding, action sizing, tooltip padding, row height, font, radius, and color tokens; extracted `Shell*.qml` components use the tokens for repeated spacing/action literals.

- [x] P0: Split `shell.qml` into a small root plus imported components.
  - Sources: Caelestia and Noctalia component boundaries; end-4 menu/component split.
  - Acceptance: `shell.qml` owns app wiring only; menu bodies, services, popups, launchers, and dashboards live in focused `Shell*.qml` files; no new abstraction unless it deletes repeated code.
  - Validation: `wc -l desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/ShellBar.qml`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: the top bar moved into `ShellBar.qml`; `shell.qml` dropped from 2362 to 2097 lines and keeps the root state, service processes, IPC handlers, wallpaper, and popup wiring.

- [x] P0: Centralize menu popup geometry and open/close behavior.
  - Sources: AGS click-away launcher behavior, Noctalia compact popups, local launcher floating rules.
  - Acceptance: launcher, clipboard, web search, calendar, controls, media, notifications, wallpaper, screen, network, power, settings, and work inbox use one menu registry for width, height, anchor, focus, Escape, and double-toggle close.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "anchor\.rect\.x: Math\.max\(8, anchorWindow\.width - implicitWidth|anchor\.rect\.y: anchorWindow\.height  6|visible: panelOpen|implicitWidth: panelWidth|implicitHeight: panelHeight" desktop/.config/quickshell/marcelof/Shell*.qml`, `desktop/tools/qs-menu-smoke controls launcher notifications calendar media clipboard`.
  - Current behavior: right-side menus use `ShellPopup`; launcher, clipboard, passmenu, and web search use `ShellFloatingPopup`; special tooltip/toast/OSD surfaces keep their custom placement.

- [x] P0: Centralize QML command actions into `ShellConfig`.
  - Sources: surface-dots config separation, Caelestia action helpers.
  - Acceptance: QML components call named helpers for audio, wallpaper, network, screenshots, browser, clipboard, power, screen recording, notifications, and settings; direct command arrays appear only in the config/action module or intentional one-off tests.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "command: \[|Quickshell\.execDetached\(\[|\[shellConfig\.bin|\[[a-zA-Z0-9_.]+Config\.bin" desktop/.config/quickshell/marcelof/*.qml`.
  - Current behavior: command arrays for bar status, weather, brightness, clipboard, passmenu, launcher MRU, screenshots, power, audio, privacy, work inbox, Pomodoro, and helpers are defined through `ShellConfig.qml`; `shell.qml` and panel components call named helpers.

- [x] P1: Build a simple menu/action registry for Controls.
  - Sources: Noctalia all-in-one controls, cxOrz quick settings.
  - Acceptance: Controls buttons are data rows from one local list, so adding/removing Wallpaper, Screen, Network, Work, Dash, Power, Settings, and Keybindings does not duplicate icon/label/action/button code.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke controls`.
  - Current behavior: Controls menu buttons now come from `menuActionRows` plus `triggerMenuAction()` in `ShellControlPanel.qml`; session commands used by Controls/Power are also routed through `ShellConfig.qml`.

- [x] P1: Normalize all menu empty/loading/error states.
  - Sources: Caelestia settings and launcher states, end-4 utility surfaces.
  - Acceptance: every popup has one shared style for empty, loading, warning, and error rows; long text wraps or elides inside the panel.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke clipboard notifications tray`.
  - Current behavior: `ShellStateBox.qml` owns the shared empty/loading state frame and text style for clipboard, passmenu, notifications, and tray manager. Contextual inline status rows remain inline for media, network, privacy, and calendar data.

- [x] P1: Dry Hyprland keybinding/profile definitions.
  - Sources: Omarchy keybinding discoverability, local generated `hypr-keys`.
  - Acceptance: default and omarchy profiles share common binding lists where behavior matches; generated help and actual binds still come from the same data.
  - Validation: `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `Hyprland --config desktop/.config/hypr/init.lua --verify-config`, `HYPR_PROFILE=omarchy Hyprland --config desktop/.config/hypr/init.lua --verify-config`, `HYPR_PROFILE=default hypr-keys`, `HYPR_PROFILE=omarchy hypr-keys`.
  - Current behavior: repeated direction and workspace-number binding loops, terminal shortcut helpers, shared action names, Ghostty class, monitor mode, Catppuccin border/group colors, and groupbar config now live in `profiles/common.lua`; `default.lua` and `omarchy.lua` keep only profile-specific binding choices.

- [x] P1: Dry Hyprland window rules and popup rules.
  - Sources: Omarchy floating utilities, local floating menu experiments.
  - Acceptance: launcher/menu/tmux popup/window floating rules are generated through one small helper/table instead of repeated `windowrulev2` blocks.
  - Validation: `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `Hyprland --config desktop/.config/hypr/init.lua --verify-config`, `HYPR_PROFILE=omarchy Hyprland --config desktop/.config/hypr/init.lua --verify-config`.
  - Current behavior: `profiles/common.lua` owns default monitor declarations, common Quickshell/floating popup rules, and dropdown tmux rules; each profile keeps only profile-specific window rules.

- [x] P1: Move board status config into data files and keep Rust code generic.
  - Sources: current board native/script check split, user request to separate config from code.
  - Acceptance: check names, labels, thresholds, script paths, and enabled/disabled flags live in board config; Rust keeps only native check implementations and render plumbing.
  - Validation: `cargo test -p board`, source and live `board --config ... doctor`, source and live `board --config ... checks`, live `board --config ... render text quickshell-bar`, `home -y`.
  - Current behavior: board defaults are TOML-backed; labels, thresholds, enabled flags, script commands, weather location, time-panel timezones, and surface membership live in config. `StatusItem.name` stays the stable cache/metric key; human output uses config `label`.

- [x] P2: Add a repetition audit helper for Quickshell and Hyprland config.
  - Sources: local DRY work, no new dependency.
  - Acceptance: one script reports top repeated QML strings/numbers/colors and repeated Hyprland command fragments, excluding obvious imports and generated text.
  - Validation: `ruby -c desktop/tools/quickshell-repeat-audit`, `desktop/tools/quickshell-repeat-audit | sed -n '1,90p'`.
  - Current behavior: `desktop/tools/quickshell-repeat-audit` uses a tiny stdlib Ruby scanner to report repeated QML string literals, numeric UI literals, and Hyprland Lua string literals for the next DRY passes.

- [x] P0: Remove the remaining repeated search-box and list-row QML.
  - Sources: current launcher, clipboard, passmenu, and web-search panels; Caelestia/end-4 reusable input and list-row components.
  - Acceptance: one tiny search input component and one tiny selectable row pattern cover launcher, clipboard, passmenu, and web search without changing behavior or adding a widget framework.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/quickshell-repeat-audit`, `bash -n desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch launcher-hidden clipboard-toggle`, `desktop/bin/qs-bar status`.
  - Current behavior: `ShellSearchBox.qml` owns the shared search input frame, placeholder, focus method, text alias, and key signals for launcher, clipboard, passmenu, and web search; `ShellSelectableRow.qml` owns the simple selected-row frame and click/hover signals for clipboard and passmenu. The launcher keeps its custom icon/action row because it is not the same simple row. `desktop/tools/qs-menu-smoke` still has no passmenu target, so passmenu is covered by QML lint in this pass.

- [x] P0: Move remaining bar and menu size literals into existing theme/config tokens.
  - Sources: `desktop/tools/quickshell-repeat-audit` repeated `height: 22`, `height: 42`, `width: 22`, margin, and row-height findings.
  - Acceptance: shared sizes like bar icon box, tray icon, search height, list row height, divider height, and standard margins live in `ShellTheme.qml` or `ShellConfig.qml`; one-off geometry remains local.
  - Validation: `desktop/tools/quickshell-repeat-audit`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `bash -n desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch notifications calendar network work-inbox`.
  - Current behavior: `ShellTheme.qml` owns shared bar height, bar icon/tray sizes, workspace indicator size, panel/input margins, search/list row heights, launcher row height, chip height, and divider height; the audit now reports only divider-style numeric literals (`width: 1`, `height: 1`).

- [x] P0: Keep `shell.qml` as wiring by moving repeated state/process blocks into focused components.
  - Sources: Caelestia/Noctalia service-state split and current extracted `Shell*.qml` components.
  - Acceptance: root keeps global wiring and IPC only; launcher, notifications, media/audio, privacy, calendar, wallpaper, and work-inbox polling/state stay next to their panels or in one small service component when shared.
  - Validation: `wc -l desktop/.config/quickshell/marcelof/shell.qml`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke launcher controls media notifications calendar wallpaper work-inbox`.
  - Current behavior: calendar/time/Pomodoro polling moved to `ShellCalendarService.qml`; Work Inbox and Personal Dashboard refreshes moved to `ShellDashboardService.qml`; wallpaper current/list polling moved to `ShellWallpaperService.qml`; screen recording and portal polling moved to `ShellScreenService.qml`; launcher MRU, clipboard, passmenu, and keybinding refreshes moved to `ShellMenuDataService.qml`; privacy, power, network, brightness, external brightness, keyboard brightness, fan, and idle-inhibit refreshes moved to `ShellSystemStatusService.qml`; audio status, audio streams, media now-playing, and audio refresh timers moved to `ShellAudioService.qml`. Root `shell.qml` has no direct `Process` blocks left.

- [x] P0: Split config data from command/action code without adding a settings framework.
  - Sources: surface-dots config separation, Caelestia action helpers, current `ShellConfig.qml`.
  - Acceptance: static user values, command paths, menu geometry, and action functions are easy to scan; `ShellConfig.qml` does not become a mixed dump of constants plus behavior.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "readonly property .*:|function .*\(" desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`, `bash -n desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch controls media notifications calendar wallpaper screen network power personal-dashboard`, `desktop/bin/qs-bar status`.
  - Current behavior: static paths, menu geometry, dashboard surface names, and calendar weekday data live in `ShellConfigData.qml`; `ShellConfig.qml` keeps command/action helpers and forwards the existing property names so call sites stay stable.

- [x] P0: Create one small section/card primitive for repeated dashboard blocks.
  - Sources: current Controls, Media, Calendar, Network, Work Inbox, and Personal Dashboard repeated `Rectangle + RowLayout + Text` blocks; Noctalia/end-4 quick-setting cards.
  - Acceptance: dashboard sections share padding, radius, border, heading/body text, and action-row layout through one existing-style primitive; no nested decorative cards.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `bash -n desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke controls media calendar network work-inbox personal-dashboard`, `desktop/bin/qs-bar status`.
  - Current behavior: `ShellSection.qml` owns the shared dashboard section frame, padding, radius, optional border, fill-height behavior, and inner layout spacing. Controls privacy, Media stream cards, Calendar Pomodoro, Network details, and Work Inbox source rows use it; Personal Dashboard was smoke-tested but left unframed to avoid adding a decorative nested card.

- [x] P1: Make the menu registry the single source for menu names, geometry, shortcuts, and smoke targets.
  - Sources: current `ShellPopup`/`ShellFloatingPopup`, Controls all-menus hub, generated keybindings, and `desktop/tools/qs-menu-smoke`.
  - Acceptance: menu id, label, shortcut, size, placement, and smoke command are not repeated separately in QML, Hyprland docs, and shell helpers unless the target truly differs.
  - Validation: `bash -n desktop/lib/lib_qs_menus.sh desktop/bin/qs-bar desktop/tools/qs-menu-smoke`, `desktop/bin/qs-bar list-menus`, `desktop/tools/qs-menu-smoke --list`, `diff -u <(desktop/bin/qs-bar list-menus) <(desktop/tools/qs-menu-smoke --list)`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke controls launcher clipboard calendar media notifications wallpaper screen network power settings`.
  - Current behavior: `desktop/lib/lib_qs_menus.sh` is the shared shell source for smoke menu names, menu labels used by generated key help, special open commands, and screenshot crop geometry; `qs-bar list-menus` and `desktop/tools/qs-menu-smoke --list` return the same list, and `diff -u <(desktop/bin/qs-bar list-menus) <(desktop/tools/qs-menu-smoke --list)` passed. QML menu sizes live in `ShellConfigData.qml` under `menuSizes`, and popup instances ask `shellConfig.menuSize(id, dense)` through `root.menuWidthFor`/`root.menuHeightFor`. Controls menu button icons, labels, tooltips, and actions live in `ShellConfigData.qml` under `controlMenuRows`; Settings menu shortcut rows live there under `settingsMenuRows`; the panels only render and dispatch them. `hypr-keys default` and `hypr-keys omarchy` now resolve Quickshell menu labels through `lib_qs_menus.sh` when the binding calls `qs-bar <menu>` or `qs("<menu>")`.

- [x] P2: Add docs for the intended component/config layout.
  - Sources: this migration queue and reference repo organization.
  - Acceptance: `docs/desktop/quickshell-architecture.md` explains root shell, components, theme/config/state, helpers, board boundary, and what not to add.
  - Validation: doc exists and links from this task file.
  - Current behavior: `docs/desktop/quickshell-architecture.md` exists and documents root/component/service/config/theme/helper ownership, board and archive boundaries, the reference import rule, and what not to abstract. Later architecture task also links this file.

- [x] P0: Add a tiny `ShellText.qml` primitive for repeated Quickshell text styling.
  - Sources: Caelestia `StyledText`, cxOrz `Theme.qml`, surface-dots `theme.js`.
  - Acceptance: common label/body/muted/title/icon text styles no longer repeat font family, style, size, and color literals across menus.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: `ShellText.qml` owns common text roles; shared buttons, tooltips, status text, and common fixed one-line menu labels now use it. Dynamic status text can still override color or size locally.

- [x] P0: Add `ShellScrollPanel.qml` or simplify scroll menus into the existing frame/panel primitives.
  - Sources: Noctalia and end-4 control/menu surfaces; Caelestia component layering.
  - Acceptance: scroll-heavy menus share the same panel frame, margins, and scrollbar policy without hand-copying the frame in every file.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls media notifications launcher clipboard passmenu`.
  - Current behavior: `ShellScrollPanel.qml` wraps the shared `ShellFrame` plus `ScrollView`; the pure scroll dashboards, Controls and Media, use it. Mixed header-plus-scroll panels keep local inner scroll areas.

- [x] P0: Move Quickshell command paths and user-tunable values into one simple config object.
  - Sources: surface-dots `config.js`, Caelestia config/state split.
  - Acceptance: browser, terminal, wallpaper, screenshot, audio, network, and state-file paths are defined in one local QML config/helper, not repeated in menu components.
  - Validation: `qmllint`, `rg -n "hypr-clean-env|audioctl|screenshot-wayland|wallpaper-wayland|network-status" desktop/.config/quickshell/marcelof/*.qml`.
  - Current behavior: `ShellConfig.qml` owns command helpers for clean-env apps, Quickshell IPC, screenshots, browser, audioctl, network-status, wallpaper, network settings, and volume mixer. The command-string grep now resolves to `ShellConfig.qml` only.

- [x] P1: Polish launcher states and ranking.
  - Sources: Caelestia launcher modes, Omarchy app menu behavior, AGS launcher close/selection behavior.
  - Acceptance: launcher keeps MRU/MFU/favorite behavior, has a clean empty state, stable keyboard focus, and consistent row actions for favorite/hide/open.
  - Validation: `desktop/tools/qs-menu-smoke launcher settings`, `qs ipc ... call launcher state` after `qs-bar launcher`, manual `Win+D`, type query, click or Enter launch, hide app, favorite app, clear hidden apps, reload.
  - Current behavior: `ShellLauncherService.qml` owns MRU/MFU scoring, favorites, hidden apps, command rows, and app activation. Launcher IPC opens with `panelOpen`, so click and Enter pass the same state guard as keyboard toggles. Click and Enter launch the visible `DesktopEntries` object through Quickshell native `execute()` first, with command/`gtk-launch` fallback; custom command rows keep direct command execution. The launcher shows a shared empty state, and Settings exposes `Clear Hidden Apps` so hidden entries are recoverable.

- [x] P1: Improve notification center grouping and details.
  - Sources: Noctalia notification center, end-4 notification surfaces, Omarchy notification service/card split.
  - Acceptance: grouped notifications preserve actions, expand/collapse cleanly, long summaries/bodies never overflow, and clicking a notification focuses the source app when possible.
  - Validation: `desktop/tools/desktop-notification-smoke actions`, `desktop/tools/qs-menu-smoke notifications`.
  - Current behavior: later notification task documents grouped history, clean expansion, clipped action rows, and source-app focus via `notification-focus-app`; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P1: Normalize the control center into one coherent dashboard.
  - Sources: Noctalia all-in-one controls, cxOrz ChromeOS-style quick settings, end-4 quick settings.
  - Acceptance: audio, brightness, network, Bluetooth, power, privacy, DND, screenshot, and session controls share row heights, spacing, hover states, and no dead right-side whitespace.
  - Validation: `desktop/tools/qs-menu-smoke controls media screen network power`.
  - Current behavior: later Controls task documents the data-driven hub and stable secondary-menu buttons; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P1: Rework media into a clean player card.
  - Sources: Caelestia MPRIS cards, Noctalia media widgets, AGS MPRIS service examples.
  - Acceptance: media menu shows player/source, title/artist, play state, local noise/music controls, stream volume rows, and pause-all without visual crowding.
  - Validation: `audioctl self-test`, `desktop/tools/qs-menu-smoke media`, manual local music/noise restore plus a normal MPRIS player.
  - Current behavior: later media task documents the compact player/stream layout, saved noise/music state, play-pause/stop/force-stop controls, and per-stream volume/mute rows; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P1: Re-polish the time/calendar dashboard.
  - Sources: Caelestia date/time dashboard and weather widgets; Noctalia calendar direction.
  - Acceptance: Lisbon time, extra timezones, timestamp formats, today highlight, weather min/max for Palmela, todo/pomodoro/timewarrior sections, and future calendar integration placeholders are visually balanced.
  - Validation: `desktop/tools/qs-menu-smoke calendar`, manual clock/timezone sanity check.
  - Current behavior: later calendar task documents Lisbon/timezones/timestamps, Palmela weather, todo, Pomodoro/Timewarrior, and today highlighting; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P2: Add a small shell settings/theme editor only for existing state.
  - Sources: Caelestia settings surface, Noctalia config boundary.
  - Acceptance: primary color, density, weather location, DND, tray menu mode, and bar visibility are editable through one menu without introducing a theme engine.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellSettingsPanel.qml desktop/.config/quickshell/marcelof/ShellSettings.qml desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellLauncherService.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `/home/marcelof/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke launcher settings controls launcher-hidden`.
  - Current behavior: Settings edits DND, native tray menus, bar visibility, density, weather location, launcher hidden apps, and the existing persisted primary color through a small swatch row. Final smoke artifact: `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-202026`.

- [x] P2: Add a cheap Quickshell runtime cleanup helper.
  - Sources: Omarchy-style doctor/maintenance direction; local finding that `qs list --all` can leave dead runtime IDs.
  - Acceptance: `qs-bar` can prune stale `/run/user/$UID/quickshell/by-path/*` dead instance entries without touching the live process.
  - Validation: `bash -n desktop/bin/qs-bar desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke desktop/bin/hypr-keys`, `desktop/bin/qs-bar runtime-prune`, `desktop/bin/qs-bar status`, `find /run/user/1001/quickshell/by-path -maxdepth 1 -mindepth 1 -printf ...`, `home -y`.
  - Current behavior: `qs-bar runtime-prune` is dry-run by default and only considers broken symlinks under `${XDG_RUNTIME_DIR:-/run/user/$UID}/quickshell/by-path`; `--force` uses `unlink` on those broken symlinks only, never `rm -rf` and never `by-id` directories. Current validation reported `no stale quickshell by-path entries`, one live Quickshell process, and one live `by-path` symlink pointing at the active shell id.

- [x] P2: Make menu screenshots a reliable visual regression workflow.
  - Sources: end-4 visual polish practice, local `desktop/tools/qs-menu-smoke`.
  - Acceptance: `desktop/tools/qs-menu-smoke` captures all main menus, stores readable PNGs, and fails when a menu renders as blank, side-window-only, or obviously clipped.
  - Validation: `desktop/tools/qs-menu-smoke all`, inspect latest screenshot folder.
  - Current behavior: `desktop/tools/qs-menu-smoke all` captures every registered menu, writes per-menu PNG/crop images plus a contact sheet and summary TSV, waits for launcher `panelOpen` through IPC before screenshotting, and `desktop/tools/desktop-doctor` validates the latest full smoke artifact.


- [x] P0: Burn down the top repeated Quickshell literals before adding features.
  - Sources: local `desktop/tools/quickshell-repeat-audit`, Caelestia/cxOrz theme-token style, surface-dots config split.
  - Acceptance: each pass removes or explains the top repeated color, font, spacing, size, and command literals; intentional repeats live in `ShellTheme.qml`, `ShellConfigData.qml`, or one focused primitive.
  - Validation: `desktop/tools/quickshell-repeat-audit`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: `ShellTheme.qml` now owns the transparent color token, all direct QML `"transparent"` uses outside the theme are gone, menu sizes, menu IDs, network labels/keywords, shared labels/actions/states, default web search provider, web search site data, and the repeated CLI `status` action live in `ShellConfigData.qml`; `desktop/tools/quickshell-repeat-audit` ignores intentional `ShellText` role assignments plus config-data literals so the report focuses on real duplication.

- [x] P0: Keep config in data files and behavior in helpers.
  - Sources: surface-dots data/config separation, Caelestia services/utils split, current `ShellConfig.qml`/`ShellConfigData.qml`.
  - Acceptance: user-tunable values, menu geometry, commands, board surfaces, weather location, and theme tokens are declarative; QML panel files call helpers and do not embed shell command arrays.
  - Validation: `rg -n "command: \[|Quickshell\.execDetached\(\[|readonly property .*: .*audioctl|readonly property .*: .*wallpaper" desktop/.config/quickshell/marcelof/*.qml` returns only approved config/helper files.
  - Current behavior: stream mute/volume commands, brightness wheel commands, repeated status commands, network matching helpers, and session power commands route through `ShellConfig.qml`; Power menu session rows now live in `ShellConfigData.qml` as `sessionActionRows`/`exitSessionAction`; menu IDs, shared labels/actions/states, network labels/keywords, and default web-search provider/site data also live in `ShellConfigData.qml`; the config-boundary grep returns no panel/root direct command-array matches.

- [x] P1: Add a tray drawer and context menu that behaves like a normal desktop tray.
  - Sources: Noctalia tray drawer/context menu, Caelestia tray controls, local tray manage panel.
  - Acceptance: tray entries expose app name, status, pin/hide, activate, and context actions where Quickshell provides them; hidden entries remain recoverable in the shell settings/control menu.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellTrayManagePanel.qml desktop/.config/quickshell/marcelof/ShellTrayButton.qml desktop/.config/quickshell/marcelof/ShellBar.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `/home/marcelof/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke controls tray`, `desktop/tools/qs-menu-smoke all`, `desktop/tools/desktop-doctor`.
  - Current behavior: the bar tray drawer exposes pinned and unpinned visible tray items, middle-click pinning, direct/network actions, native menu display when enabled, activation, and scroll forwarding. The Tray manager now shows every tray item including hidden ones, displays pinned/drawer/hidden plus menu status, and provides Activate, Menu/action, Pin, and Hide buttons so hidden entries remain recoverable.

- [x] P1: Normalize the existing volume/brightness OSD surfaces.
  - Sources: Caelestia OSD, end-4/noctalia quick feedback surfaces, existing local OSD behavior.
  - Acceptance: hardware volume, mute, mic mute, and brightness overlays reuse the same small surface, theme tokens, timeout, and icon sizing without opening the full controls menu.
  - Validation: `bash -n desktop/tools/qs-menu-smoke desktop/lib/lib_qs_menus.sh desktop/bin/qs-bar`, `qmllint desktop/.config/quickshell/marcelof/ShellOverlays.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `desktop/tools/qs-menu-smoke osd`.
  - Current behavior: volume, mute, mic mute, brightness, and keyboard brightness all route through the shared `ShellOverlays` OSD surface. `desktop/tools/qs-menu-smoke osd` now triggers the existing `qs-bar osd-volume` IPC, captures the overlay, crops it with shared geometry, and passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-202553`.

- [x] P1: Make clipboard/pass/search picker paths share one launcher primitive.
  - Sources: Caelestia launcher modes, AGS picker patterns, local Walker/passmenu migration.
  - Acceptance: app launcher, web search, clipboard, and passmenu share focus, close, empty state, row spacing, and keyboard navigation; backend-specific code is only data fetch plus activation.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/ShellWallpaperService.qml desktop/.config/quickshell/marcelof/ShellWallpaperPanel.qml desktop/.config/quickshell/marcelof/ShellCalendarPanel.qml desktop/.config/quickshell/marcelof/ShellPersonalDashboardPanel.qml desktop/.config/quickshell/marcelof/ShellPickerList.qml desktop/.config/quickshell/marcelof/ShellClipboardPanel.qml desktop/.config/quickshell/marcelof/ShellPassMenuPanel.qml desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/ShellLauncherService.qml`, `bash -n desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/lib/lib_qs_menus.sh`, `desktop/tools/quickshell-repeat-audit`, `home -y`, `/home/marcelof/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch passmenu launcher-hidden clipboard-toggle`, `/home/marcelof/bin/qs-bar list-menus`.
  - Current behavior: `ShellPickerList.qml` now owns picker list visibility, spacing, current-index movement, and current-row positioning for launcher, clipboard, and passmenu. Web search keeps the same shared `ShellSearchBox` one-shot command surface. `qs-bar passmenu` now calls the typed passmenu IPC with default copy/username/gopass args, `passmenu` is included in `desktop/lib/lib_qs_menus.sh`, and focused smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-205754`.

- [x] P1: Add meeting-aware DND/privacy status without guessing app internals.
  - Sources: Noctalia privacy indicators, local Google Meet/screenshare/mic issues, PipeWire portal status.
  - Acceptance: bar/control center distinguishes mic, camera, screen share, and DND; audioctl pause-all never touches meeting/browser capture sessions.
  - Validation: `desktop/bin/desktop-privacy-status self-test`, `desktop/bin/audioctl self-test`, `qmllint desktop/.config/quickshell/marcelof/ShellBar.qml desktop/.config/quickshell/marcelof/ShellControlPanel.qml desktop/.config/quickshell/marcelof/ShellScreenPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke controls screen`, `desktop/tools/desktop-doctor`.
  - Current behavior: the bar shows separate mic, camera, screen-share/record, and DND icons from `desktop-privacy-status`; left click opens Screen details and right click toggles DND. Controls shows the same privacy state plus refresh/details actions. `audioctl self-test` proves pause/resume/force-stop only touch helper-owned noise/music and leave an unmanaged process alive, so browser/meeting audio is not controlled by pause-all.

- [x] P1: Add a tiny system-health details page instead of crowding the bar.
  - Sources: Caelestia dashboard modules, board native checks, current bar status pressure.
  - Acceptance: bar keeps short icons only; details for clock sync, DNS, Docker, safe status, CPU, memory, temperature, weather, fan, and battery health live in one popup page.
  - Validation: `board render text quickshell-bar`, `desktop/tools/qs-menu-smoke controls personal-dashboard`.
  - Current behavior: the existing Personal dashboard now includes a `system` tab backed by `board render text quickshell-bar`, keeping the bar compact while exposing board health details in a popup surface. Validation passed for focused `qmllint`, `board --config desktop/.config/board/board.toml render text quickshell-bar`, `home -y`, `/home/marcelof/bin/qs-bar reload`, and `desktop/tools/qs-menu-smoke controls personal-dashboard` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-200754`.

- [x] P2: Add wallpaper/theme preview workflow without a full theme engine.
  - Sources: Caelestia wallpaper handling, end-4 wallpaper/theme panels, current Catppuccin lavender primary color.
  - Acceptance: wallpaper menu previews current/next wallpaper, can apply it, and optionally updates only the existing primary/accent tokens.
  - Validation: `desktop/tools/qs-menu-smoke wallpaper`, manual apply/reload smoke.
  - Current behavior: wallpaper menu shows a current/hover preview image, opens the current wallpaper, refreshes the list, opens the wallpaper folder, and applies a selected image through `wallpaper-wayland set` without adding a theme engine. Validation passed for focused `qmllint`, `home -y`, `/home/marcelof/bin/qs-bar reload`, `wallpaper-wayland status`, no-op apply with the current wallpaper, and `desktop/tools/qs-menu-smoke wallpaper` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-200440`.

- [x] P2: Document the reference-repo import rule.
  - Sources: Omarchy, Caelestia, end-4, Noctalia, cxOrz, surface-dots, Aylur AGS, ML4W, JaKooLit.
  - Acceptance: docs state what ideas we copied, what we intentionally did not copy, and the rule: reuse ideas/patterns, avoid upstream-branded binaries and broad framework rewrites.
  - Validation: doc link from this task file.
  - Current behavior: `docs/desktop/wayland.md` has a `Reference Import Rule` section that names adapted ideas, rejected imports, and the local rule to reuse patterns without upstream-branded binaries or broad shell rewrites.

### 2026-08-03 Follow-Up Task Batch

Task source: latest local review request. Priority is code repetition and simple config first, then the highest-value UX gaps already seen in the local reference set.

- [x] P0: Move agent validation helpers out of the runtime bin surface.
  - Sources: user request to separate validation/helper scripts, current `desktop/bin` clutter, local `home -y` copy behavior.
  - Acceptance: agent/validation-only scripts live under `desktop/tools`; runtime commands used by Hyprland/Quickshell remain in `desktop/bin`; validation tools can still call each other from their new folder.
  - Validation: `bash -n desktop/tools/desktop-doctor desktop/tools/desktop-accept desktop/tools/desktop-package-audit desktop/tools/desktop-notification-smoke desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`.
  - Current behavior: `desktop-accept`, `desktop-doctor`, `desktop-package-audit`, `desktop-notification-smoke`, `qs-menu-smoke`, and `quickshell-repeat-audit` moved to `desktop/tools`; `desktop-doctor` and `desktop-accept` prepend their tool directory to `PATH`.

- [x] P0: Fix `Win+D` app selection and remove the duplicate launcher wrapper.
  - Sources: live launcher IPC smoke, current Quickshell `DesktopEntries` API, redundant `qs-launcher` wrapper.
  - Acceptance: `Win+D`/`Win+Space` open the launcher through `qs-bar launcher`; selecting an app launches the Quickshell desktop-entry object with command/`gtk-launch` fallback; the old wrapper is archived, not deleted.
  - Validation: `desktop/tools/qs-menu-smoke launcher`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, manual `Win+D` open/type/Enter.
  - Current behavior: both active Hyprland profiles bind launcher keys to `qs-bar launcher`; `archive/obsolete/desktop/bin/qs-launcher` keeps the retired wrapper for history. Launcher IPC sets `panelOpen`, so click and Enter route through the visible `DesktopEntries` object in `ShellLauncherService.qml`; Settings exposes `Clear Hidden Apps` for hidden-entry recovery.

- [x] P1: Continue reducing Quickshell/Hyprland runtime script count by call-site audit only.
  - Sources: user request to reduce script count, current runtime helpers, Ponytail/YAGNI rule.
  - Acceptance: remove or archive only scripts proven redundant by `rg` call-site checks; keep scripts that represent real runtime boundaries such as audio, privacy, screenshots, wallpaper, monitor, and browser wrappers.
  - Validation: `rg -n "bin\(\\"|qs\(|exec|command -v" desktop/.config/quickshell/marcelof desktop/.config/hypr desktop/bin desktop/tools desktop/lib`, `bash -n desktop/bin/qs-bar desktop/bin/desktop-osd desktop/bin/audioctl desktop/bin/screenshot-wayland desktop/bin/wallpaper-wayland desktop/bin/screen-record-wayland desktop/bin/desktop-privacy-status desktop/bin/network-status desktop/tools/desktop-doctor`, `desktop/tools/qs-menu-smoke all`, `desktop/tools/desktop-doctor`, `home -y`.
  - Current behavior: the call-site audit did not prove any additional active runtime wrapper redundant. `qs-bar`, `desktop-osd`, `audioctl`, screenshot, wallpaper, screen-record, privacy, network, browser, picker, and board/status helpers remain real runtime boundaries. During validation, targeted smoke checks were fixed so they no longer clobber the full-smoke `latest` pointer; `desktop/tools/qs-menu-smoke osd` now reports `latest unchanged`, full smoke restored `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-202905`, and `desktop/tools/desktop-doctor` passes.

- [x] P0: Make `desktop/tools/quickshell-repeat-audit` a gate for every Quickshell pass.
  - Sources: local repetition audit, current `ShellTheme.qml`/`ShellConfigData.qml` split.
  - Acceptance: the audit has an allowlist for intentional repeats and fails on new repeated literals outside theme/config/component primitives.
  - Validation: `ruby -c desktop/tools/quickshell-repeat-audit`, `desktop/tools/quickshell-repeat-audit`, temporary non-allowlisted repeat fixture.
  - Current behavior: repeated literals are printed as `allowed` or `BLOCK`; the script exits 1 on any non-allowlisted repeated literal and exits 0 for the current intentional repeats.

- [x] P0: Finish the QML config boundary.
  - Sources: Caelestia config/state split, surface-dots config file layout, current `ShellConfig.qml`/`ShellConfigData.qml`.
  - Acceptance: panel components do not define command arrays, app paths, static labels, menu ids, menu sizes, theme colors, or user-tunable values; they only render data and call named helpers.
  - Validation: boundary `rg` returns no matches, `qmllint desktop/.config/quickshell/marcelof/ShellTheme.qml desktop/.config/quickshell/marcelof/ShellControlPanel.qml`, `desktop/tools/quickshell-repeat-audit`.
  - Current behavior: command arrays, app paths, static menu data, and user-tunable values are routed through `ShellConfig.qml`, `ShellConfigData.qml`, or `ShellTheme.qml`; the last controls menu width literal moved into `ShellTheme.qml`.

- [x] P0: Finish splitting `shell.qml` down to root wiring only.
  - Sources: Caelestia services/components, Noctalia modules, end-4 widgets.
  - Acceptance: `shell.qml` owns windows, IPC, and top-level state only; any repeated visual block, service process, or menu body lives in a focused `Shell*.qml` component.
  - Validation: `wc -l desktop/.config/quickshell/marcelof/shell.qml`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: OSD state/display/timers and notification toast timing moved into `ShellOverlays.qml`; calendar grid helpers moved into `ShellCalendarPanel.qml`; launcher ranking/activation moved into `ShellLauncherService.qml`; polling/process blocks live in focused service components, and `shell.qml` has no direct `Process` blocks left. `shell.qml` is 1465 lines and focused QML lint passed. Remaining root-owned code is top-level state, IPC, and glue that crosses panels.

- [x] P0: Move board check metadata out of Rust.
  - Sources: current board config, user request to keep config in one place and code generic.
  - Acceptance: board check labels, thresholds, enabled flags, script paths, and surface membership live in TOML; Rust keeps only native check implementations and rendering.
  - Validation: `cargo test -p board`, source and live `board --config ... doctor`, source and live `board --config ... checks`, live `board --config ... render text quickshell-bar`, release install to `~/bin/board`, `home -y`.
  - Current behavior: config owns check labels, thresholds, enabled flags, script commands, weather location, time-panel timezones, and surface membership. Rust keeps native check implementations, render plumbing, and stable `StatusItem.name` cache/metric keys; human `checks` and TUI output use config labels.

- [x] P1: Make the menu registry the single source across QML, scripts, and key help.
  - Sources: local `lib_qs_menus.sh`, Controls menu, `hypr-keys`, `desktop/tools/qs-menu-smoke`.
  - Acceptance: menu id, label, shortcut, smoke target, geometry, and placement are declared once or generated from the same small data source.
  - Validation: `desktop/bin/qs-bar list-menus`, `desktop/tools/qs-menu-smoke --list`, `diff -u <(desktop/bin/qs-bar list-menus) <(desktop/tools/qs-menu-smoke --list)`, `bash -n desktop/lib/lib_qs_menus.sh desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/bin/hypr-keys`, `desktop/bin/hypr-keys default`, `desktop/bin/hypr-keys omarchy`, `desktop/tools/qs-menu-smoke launcher clipboard websearch passmenu controls media notifications calendar wallpaper screen network power settings tray personal-dashboard`.
  - Current behavior: `desktop/lib/lib_qs_menus.sh` owns shell-side menu ids, labels for generated key help, open dispatch, and smoke crop geometry. `qs-bar list-menus` and `desktop/tools/qs-menu-smoke --list` are identical. `hypr-keys` parses the active Hyprland profile for shortcuts and asks `lib_qs_menus.sh` for Quickshell menu labels, so shortcut help is generated from the real bindings plus the shared menu label registry. QML menu sizes, control rows, settings rows, and dashboard surfaces remain in `ShellConfigData.qml`, which is the QML-side data source consumed by panel instances through `ShellConfig.qml`.

- [x] P1: Normalize all popup menus to the same shell primitives.
  - Sources: Noctalia compact popups, AGS launcher behavior, current `ShellPopup` and `ShellFloatingPopup`.
  - Acceptance: launcher, clipboard, passmenu, web search, calendar, controls, media, notifications, wallpaper, screen, network, power, settings, tray, and dashboards share focus, Escape, double-toggle, click-away, empty/loading/error state, row sizing, and clipping behavior.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellFloatingPopup.qml desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/ShellClipboardPanel.qml desktop/.config/quickshell/marcelof/ShellPassMenuPanel.qml desktop/.config/quickshell/marcelof/ShellWebSearchPanel.qml desktop/.config/quickshell/marcelof/ShellPickerList.qml desktop/.config/quickshell/marcelof/ShellLauncherService.qml`, `bash -n desktop/bin/qs-bar desktop/tools/qs-menu-smoke desktop/lib/lib_qs_menus.sh desktop/bin/hypr-keys`, `desktop/tools/quickshell-repeat-audit`, `home -y`, `/home/marcelof/bin/qs-bar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch passmenu controls media notifications calendar wallpaper screen network power settings tray personal-dashboard`.
  - Current behavior: `ShellFloatingPopup.qml` owns the Hyprland focus grab for floating picker popups and emits one `focusCleared` signal; launcher, clipboard, passmenu, and web search now only provide their close action. `ShellPickerList.qml` owns list spacing, visibility, current-index movement, and current-row positioning for picker lists, while anchored menus continue through `ShellPopup`/`ShellPanel`. Focused popup smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-210254`.

- [x] P1: Add screenshot-backed visual regression for shell menus.
  - Sources: existing `desktop/tools/qs-menu-smoke`, local screenshot workaround docs, user reports that menus regress visually.
  - Acceptance: one command opens each menu, captures readable PNGs, detects blank/clipped/side-window render failures, and stores artifacts for comparison.
  - Validation: `desktop/tools/qs-menu-smoke all`, `desktop/tools/desktop-doctor`.
  - Current behavior: default-speed full smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-193908`; launcher open is state-gated through IPC so the first floating popup no longer needs a manual slow smoke run.

- [x] P1: Rebuild the Controls dashboard as the hub for secondary menus.
  - Sources: Noctalia/cxOrz quick settings, current Controls menu and user request for buttons to every menu.
  - Acceptance: Controls exposes stable buttons for screen, network, audio, media, wallpaper, clipboard, notifications, tray, keybindings, settings, power, and personal dashboard without duplicate keybindings for the same action.
  - Validation: `desktop/tools/qs-menu-smoke controls screen network media wallpaper clipboard notifications tray power settings keybindings`.
  - Current behavior: Controls exposes data-driven hub buttons for apps, web, keybindings, clipboard, wallpaper, screen, audio/media, network, calendar, work inbox, personal dashboard, notifications, settings, tray, and power. The Power menu is now in the menu-row registry, and the Media button is explicitly the audio/media surface. Validation passed after `home -y` and `/home/marcelof/bin/qs-bar reload` with `desktop/tools/qs-menu-smoke controls screen network media wallpaper clipboard notifications tray power settings keybindings personal-dashboard` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-200032`.

- [x] P1: Clean up media/audio UI without changing `audioctl` behavior.
  - Sources: Caelestia MPRIS cards, Noctalia media widgets, local `audioctl` regressions.
  - Acceptance: media menu uses one player card layout, shows local noise/music and MPRIS players clearly, exposes play/pause/stop/restore/kill safely, and never pauses browser meeting audio.
  - Validation: `audioctl self-test`, `desktop/tools/qs-menu-smoke media`, manual local noise plus music restore.
  - Current behavior: media menu uses one compact player/stream layout, shows MPRIS now-playing text plus saved noise/music state, exposes previous/play-pause/next, noise/music toggles, stop/force-stop, output mixer, default output slider, and per-stream volume/mute controls. `audioctl self-test` proves saved noise/music restore and force-stop behavior without touching browser meeting audio, and `desktop/tools/qs-menu-smoke media` passed.

- [x] P1: Improve notification center behavior and app focus.
  - Sources: Noctalia notification center, end-4 notification surfaces, local `notification-focus-app`.
  - Acceptance: grouped notifications expand/collapse without text overflow, action buttons remain usable, and clicking a notification focuses the matching app where Hyprland client metadata permits it.
  - Validation: `desktop/tools/desktop-notification-smoke actions`, `notification-focus-app --self-test`, `desktop/tools/qs-menu-smoke notifications`.
  - Current behavior: notification center groups history by app, expands a selected notification without collapsed-body overflow, keeps action buttons inside clipped rows, and routes `Open` through `notification-focus-app` using desktop-entry/app metadata. Validation passed for `desktop/tools/desktop-notification-smoke actions`, `notification-focus-app --self-test`, `desktop/tools/qs-menu-smoke notifications`, and focused `qmllint`.

- [x] P1: Finish the calendar/time dashboard.
  - Sources: Caelestia date/weather widgets, current time panel, user requests for Lisbon, Palmela, timestamps, todo, Pomodoro, and timewarrior.
  - Acceptance: calendar highlights today with the primary color, shows Lisbon plus configured timezones, timestamp formats, Palmela today/tomorrow min-max weather, todo, and a designed Pomodoro/timewarrior placeholder.
  - Validation: `desktop/tools/qs-menu-smoke calendar`, `check-time-panel`, `check-weather`.
  - Current behavior: calendar QML highlights today with `shellSettings.primaryColor`, shows Lisbon/timezone/timestamp output from `check-time-panel`, Palmela today/tomorrow min-max weather from `check-weather panel`, ready tasks from `check-todo-panel`, and Pomodoro/Timewarrior state through `pomodoroctl`. Validation passed for `desktop/tools/qs-menu-smoke calendar`, `check-time-panel`, `WEATHER_LOCATION="Palmela, Portugal" check-weather panel`, and `check-todo-panel`.

- [x] P1: Keep Hyprland profiles DRY and discoverable.
  - Sources: Omarchy keybinding discoverability, local `profiles/common.lua`, `hypr-keys`.
  - Acceptance: default and omarchy profiles share common actions/window rules through `common.lua`; only true profile differences stay in profile files; `hypr-keys` renders current behavior from the same data.
  - Validation: `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `HYPR_PROFILE=default hypr-keys`, `HYPR_PROFILE=omarchy hypr-keys`.
  - Current behavior: `profiles/common.lua` owns shared colors, group config, monitor defaults, popup/dropdown rules, direction loops, workspace-number loops, terminal detection, and shared action names. `hypr-keys` renders readable current behavior for both profiles, including Quickshell IPC, OSD, screenshot, and tmux popup actions.

- [x] P2: Document the final Quickshell/Hyprland architecture.
  - Sources: this task file, reference repo review, local extracted components.
  - Acceptance: docs explain shell root, services, primitives, config data, theme tokens, menu registry, board boundary, archive rule for X11 code, and what not to abstract.
  - Validation: `test -s docs/desktop/quickshell-architecture.md`, link from this task file.
  - Current behavior: `docs/desktop/quickshell-architecture.md` documents root/component/service/config/theme/helper ownership, board and archive boundaries, the reference import rule, and the "do not abstract" rule.

## Board And Quickshell Performance Boundary

- [x] P0: Measure the current Quickshell status polling cost before moving code.
  - Sources: rush `board/docs/design.md`, current `StatusText.qml`, current bar `board render` every second.
  - Acceptance: one note records idle CPU, process spawn rate, and the active `StatusText` timers for the current shell; the result decides whether a daemon/watch change is worth doing now.
  - Validation: `ps -eo comm,args`, `pidstat` or `perf stat` when available, `desktop/bin/qs-bar status`, and a short before/after note in this file.
  - Current behavior: before the change, `ShellBar.qml` ran `board render quickshell quickshell-bar` through `StatusText` every second. A short `pidstat` sample showed Quickshell around 0.66% CPU idle and no persistent board renderer, so the waste was process churn more than board CPU.

- [x] P0: Replace the per-second `board render` bar poll with a board daemon/watch path.
  - Sources: rush board design says `board run` owns scheduling and Quickshell should read snapshots or subscribe to daemon events instead of polling cache files every second.
  - Acceptance: Quickshell no longer starts a new `board render quickshell quickshell-bar` process every second; it consumes one long-running board stream or snapshot watcher, and `board render` stays useful for CLI/debug fallback.
  - Validation: `desktop/bin/qs-bar status`, process-spawn count before/after, `desktop/tools/qs-menu-smoke controls personal-dashboard`, and `desktop/tools/desktop-doctor`.
  - Current behavior: `board render --watch quickshell quickshell-bar` is installed and runs as one long-lived child of Quickshell. `StatusText.watch` consumes the newline-delimited stream, while one-shot `board render quickshell quickshell-bar` still works for CLI/debug.

- [x] P0: Keep Quickshell-native service facts out of board unless measurement proves a need.
  - Sources: Quickshell UPower/PipeWire/SystemTray/Notifications services and rush board boundary.
  - Acceptance: battery stays in Quickshell UPower; tray, notifications, workspace/window state, and direct UI interaction state stay in Quickshell. Board does not duplicate those services just to render the bar.
  - Validation: `rg -n "UPower|Pipewire|SystemTray|Notifications" desktop/.config/quickshell/marcelof`, `rg -n "battery|tray|notification|workspace" desktop/.config/board board/src` with expected boundary notes.
  - Current behavior: battery, PipeWire/media, tray, notifications, workspaces, popups, and direct interaction state remain Quickshell-owned. Board only renders the status segment stream.

- [x] P1: Move remaining hot command-backed status checks toward native board modules or event hooks.
  - Sources: board design native/module/event sections, current `kind = "command"` checks for scripts, alerts, agents, and gpg.
  - Acceptance: hot-path render never runs shell scripts; command checks either run only in the board scheduler, become native modules, or receive event updates plus slow reconciliation.
  - Validation: `board --config ~/.config/board/board.toml checks`, `board render quickshell quickshell-bar` under tracing, and no command-backed check executes from the common render path.
  - Current behavior: `board render` and `board render --watch` are cache-only for `kind = "command"`; missing command cache renders `pending`, stale command cache keeps the last scheduler value, and `board run` is started from both Hyprland profiles. `desktop/tools/desktop-doctor` now fails if the scheduler is not running.

- [x] P1: Move battery thresholds and icon/color policy into declarative shell config only if the rules change again.
  - Sources: current Quickshell UPower battery widget and repeated user tuning requests.
  - Acceptance: battery remains Quickshell-native, but thresholds/colors/icons are easy to tune without editing logic; skip this if the current hardcoded four-rule policy stays stable.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellBar.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`.
  - Current behavior: `ShellConfigData.qml` owns `batteryPolicy` for full hiding, charge/full/discharge color roles, 15/30 percent critical/warning thresholds, and percent-to-icon mapping. `ShellBar.qml` only reads UPower and applies that policy.

## 2026-08-04 Visual Follow-Up

- [x] P1: Fix notification popup clipping from screenshot inspection.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported clipped notification rows and an unreadable header action label.
  - Acceptance: notification rows do not clip collapsed or expanded content, header actions are readable, and the empty-state panel stays compact.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellNotificationCenter.qml`, `desktop/tools/qs-menu-smoke --inspect notifications`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: notification group rows are 40px, collapsed rows are 76px, expanded rows use content height with padding, delegates clip their own content, and the header clear buttons have readable `App` and `All` labels. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-195814` reported no clipped popup content, overlap, unreadable text, or regression.

- [x] P1: Fix Network popup readability and dead space from screenshot inspection.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported small Network status text and then oversized empty space in the device list.
  - Acceptance: Network details are readable, controls remain intact, and the device list does not stretch into a large empty panel.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellNetworkPanel.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`, `desktop/tools/qs-menu-smoke --inspect network`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Network popup height is compact, device details use larger wrapped text, the device section has a fixed useful minimum instead of filling dead space, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-200534` reported no visible defects or regressions.

- [x] P1: Fix Wallpaper popup compact layout and screenshot coverage.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a blank Wallpaper body, but `desktop/lib/lib_qs_menus.sh` cropped only the top 150px of a taller popup.
  - Acceptance: Wallpaper visual inspection captures the preview and list area instead of only the header slice.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellWallpaperPanel.qml`, `bash -n desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke desktop/bin/qs-bar`, `desktop/tools/qs-menu-smoke --inspect wallpaper`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: the Wallpaper popup uses a compact current-wallpaper thumbnail row plus a content-sized list, and the smoke crop is 430px high so visual review includes the whole body. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-201610` reported no clipping, overlap, unreadable text, broken controls, huge empty area, or regression.

- [x] P1: Compact Media popup empty area.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a large unused area below Media playback controls when there are no active streams.
  - Acceptance: Media keeps the existing controls and stream scroll behavior, but the no-stream popup no longer has a large blank lower body.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellMediaPanel.qml`, `desktop/tools/qs-menu-smoke --inspect media`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Media popup height is 260px, keeping the controls visible while avoiding the previous no-stream dead area. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-202156` reported readable text, intact controls, no overlap, no clipped content, and no unusually huge empty area.

- [x] P1: Compact Personal dashboard empty area.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a very large empty area after the Personal dashboard status list.
  - Acceptance: Personal keeps its existing board-backed surfaces and scroll behavior, but the default surface renders readable todo content instead of falling back to the icon-only bar.
  - Validation: `board --config desktop/.config/board/board.toml doctor`, `board --config desktop/.config/board/board.toml render text personal.today`, `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellPersonalDashboardPanel.qml`, `desktop/tools/qs-menu-smoke --inspect personal-dashboard`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Personal dashboard height is 240px, `personal.today` maps to the todo board check, placeholder personal surfaces no longer fall back to the bar, personal surfaces render as plain preformatted text, and the action button uses a short Run label. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-203103` reported no clipping, overlap, unreadable text, broken controls, or meaningful regression.

- [x] P1: Compact Web search floating popup.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a huge empty area in the Web search popup; `profiles/common.lua` still forced `quickshell-websearch` to 640x220.
  - Acceptance: Web search keeps provider chips and input visible without a large blank body, and shared floating pickers keep explicit size tokens.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellFloatingPopup.qml desktop/.config/quickshell/marcelof/ShellSearchBox.qml desktop/.config/quickshell/marcelof/ShellWebSearchPanel.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `desktop/tools/qs-menu-smoke --inspect websearch`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Web search uses a 112px QML/menu size, Hyprland floats it at 640x112, the smoke crop is 124px high, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-204455` reported no overlap, unreadable text, broken controls, clipped popup content, or regression.

- [x] P1: Fix Password popup bottom-row clipping.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported the Passwords popup lower list content clipped at the bottom with no clear scroll affordance.
  - Acceptance: Password entries render without visible bottom clipping, existing search/list behavior stays unchanged, and Quickshell IPC remains healthy.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellPassMenuPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `home -y`, `hyprctl reload`, `qs-bar restart`, `desktop/tools/qs-menu-smoke --inspect passmenu`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Password popup QML and Hypr floating rule use a 544px height, dense mode uses 500px, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-205920` reported no clipped popup content, overlap, unreadable text, broken controls, huge empty area, or regression.

- [x] P1: Fix Launcher popup bottom clipping.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported the Launcher popup bottom label/text clipped at the lower edge, and live geometry showed Hyprland had previously forced a shorter launcher window than the QML menu token.
  - Acceptance: Launcher opens as a floating popup with a whole-row list viewport, no visible bottom clipping, and existing search/favorite/hide/launch behavior unchanged.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `home -y`, `hyprctl reload`, `qs-bar restart`, `hyprctl clients -j`, `desktop/tools/qs-menu-smoke --inspect launcher`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Launcher QML and Hypr floating rule use a 714px height, live Hyprland reported `size=720x714`, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-210814` reported no clipped popup content, no internal overlap, no broken controls, no huge empty area, and no launcher regression.

- [x] P1: Fix Work Inbox action button clipping.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported Work Inbox right-side action buttons clipped as `Op...`.
  - Acceptance: Work Inbox `Open` buttons render readable labels without clipping, while Slack/GitHub/Linear rows and refresh behavior stay unchanged.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellWorkInboxPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `qs-bar restart`, `QS_MENU_SMOKE_SLEEP=1.5 desktop/tools/qs-menu-smoke --inspect work-inbox`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Work Inbox uses 78px `Open` buttons, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-211633` reported no clipped content, no overlap, readable text, intact controls, no huge empty area, and no regression.

- [x] P1: Add Launcher bottom breathing room.
  - Sources: fresh `desktop/tools/qs-menu-smoke --inspect` still reported Launcher bottom item text clipped at the lower edge after the previous size alignment.
  - Acceptance: Launcher list keeps whole-row geometry, has real layout spacing above the bottom frame, and existing search/favorite/hide/launch behavior stays unchanged.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `home -y`, `hyprctl reload`, `qs-bar restart`, `hyprctl clients -j`, `desktop/tools/qs-menu-smoke --inspect launcher`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Launcher list has a 12px layout bottom margin, launcher size is 720x726, live Hyprland reported `size=720x726`, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-212612` reported no clipped popup content, overlap, unreadable text, broken controls, or huge empty area.

- [x] P1: Make Calendar dashboard scroll instead of cramming bottom sections.
  - Sources: fresh visual smoke showed Calendar was functionally healthy but dense after weather, Pomodoro, timezones, agenda, and ready tasks accumulated in one fixed-height panel.
  - Acceptance: Calendar keeps all existing sections, but overflow uses the shared scrollable panel behavior instead of shrinking lower content into an unreadable stack.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellCalendarPanel.qml desktop/.config/quickshell/marcelof/ShellScrollPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `qs-bar restart`, `desktop/tools/qs-menu-smoke calendar`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Calendar uses `ShellScrollPanel`, reusing the existing shared popup scrolling frame while keeping the month grid, Palmela weather, Pomodoro, timezone/timestamp, agenda, and ready-task sections intact. Full smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-213303`.

## 2026-08-04 Notification Follow-Up

- [x] P1: Render Android-like app icons and notification images.
  - Sources: user request for Android-style notifications; Quickshell `Notification.appIcon`, `Notification.image`, `desktopEntry`, `hasActionIcons`, and current `ShellNotificationCenter` grouped rows.
  - Acceptance: toast and notification-center rows show the sender app icon when available, fall back to desktop-entry/app initials when not, and show notification images as bounded thumbnails without stretching rows or clipping text.
  - Dependencies: keep Quickshell as the notification server; no external daemon replacement.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellNotificationCenter.qml desktop/.config/quickshell/marcelof/ShellOverlays.qml desktop/.config/quickshell/marcelof/shell.qml`, send icon and image notifications with `notify-send`, `desktop/tools/qs-menu-smoke --inspect notifications`, and `desktop/tools/desktop-notification-smoke actions`.
  - Current behavior: notification history stores `appIcon` and `image`; toasts and notification-center rows render app icons via `Quickshell.iconPath`, pass through `file://` and `image://` payloads, fall back to app initials for grouped rows, and show expanded notification images as bounded thumbnails.

- [x] P1: Add notification routing policy for neutral vs attention-worthy events.
  - Sources: user request that neutral notifications go only to the main place; current DND and notification-history model.
  - Acceptance: Quickshell records every non-transient notification in history, but only shows popup toasts for urgent notifications, configured important apps, or notifications with configured important actions/patterns. Neutral notifications increment the bar count and appear in the notification center only.
  - Dependencies: add a small declarative policy map in `ShellConfigData.qml`; avoid per-app logic scattered through QML.
  - Validation: `desktop/tools/desktop-notification-smoke routing` covers neutral and urgent notifications, `desktop/tools/qs-menu-smoke notifications controls`, and manual Slack/Chrome notification sanity check.
  - Current behavior: notification history still records every notification, but popup toasts are limited to critical urgency, configured important apps, configured action labels, or configured text patterns in `ShellConfigData.qml`; neutral notifications update the bar count and notification center only.

- [ ] P1: Make notification action buttons visually reliable.
  - Sources: `desktop/tools/qs-menu-smoke --inspect notifications` reported that the action-smoke card promises `Open` and `Done`, but only the generic `Open` focus button is visible.
  - Acceptance: notification cards clearly separate the source-app `Open` button from live notification actions, and action labels fit without truncation or disappearing.
  - Validation: `desktop/tools/desktop-notification-smoke actions`, `desktop/tools/qs-menu-smoke --inspect notifications`, and manual action notification check.

- [ ] P1: Support sticky notifications until they are completed or dismissed.
  - Sources: user request for permanent notifications until something is done; Quickshell `resident`, `expireTimeout`, `transient`, and notification actions.
  - Acceptance: notifications marked resident, no-timeout, urgent, or matched by local policy stay visible in the notification center until dismissed/actioned; invoking an action only removes the card when the source notification is not resident or the local policy says the task is complete.
  - Dependencies: live actions still require the Quickshell notification object; durable history cannot replay arbitrary D-Bus action callbacks after reload.
  - Validation: `notify-send -t 0`, action smoke notification, reload with `qs-bar restart`, and `desktop/tools/qs-menu-smoke --inspect notifications`.

- [ ] P1: Persist safe notification history to disk.
  - Sources: user request for notification history; current in-memory `notificationHistory` capped at 50.
  - Acceptance: new notifications append sanitized metadata to a JSONL file under Quickshell state, capped/rotated to a small bounded size; stored data includes app, summary, body, time, urgency, desktop entry, icon/image references when safe, and whether live actions are still available.
  - Dependencies: do not store secrets from password helpers; keep body markup sanitized like the current QML text path.
  - Validation: send notifications, restart Quickshell, verify history survives in the center or CLI, run `desktop/tools/desktop-doctor`, and inspect the JSONL for bounded size and no obvious markup leakage.

- [ ] P2: Add `notificationctl` CLI/TUI backed by Quickshell history.
  - Sources: user request for a terminal CLI/TUI; current `qs-bar notifications`, `notification-focus-app`, and existing terminal-first helpers.
  - Acceptance: `notificationctl list`, `notificationctl open <id>`, `notificationctl clear <id|app|all>`, and `notificationctl tui` operate on the same persisted history; live notifications can still invoke actions through Quickshell IPC, while old entries can focus/open the source app.
  - Dependencies: depends on persisted history and a minimal Quickshell IPC command surface for clear/open/action.
  - Validation: `bash -n desktop/bin/notificationctl`, self-test with fake JSONL, manual `notificationctl tui`, and `desktop/tools/desktop-notification-smoke actions`.


## 2026-08-05 Reliability Follow-Up

- [x] P0: Make desktop-doctor trustworthy before more UI work.
  - Sources: user request to prioritize reliable acceptance, plus recent false failures from active helper audio and stale board agent cache.
  - Acceptance: validation and agent-only helpers do not live in user-facing `desktop/bin`, duplicate wrappers are merged where practical, board uses a direct supported command for agent status, and `desktop-doctor` does not run `audioctl self-test` while helper-owned noise/music are active.
  - Validation: `bash -n desktop/bin/agent-tmux desktop/tools/ai-stack-doctor desktop/tools/desktop-doctor desktop/tools/desktop-accept`, `agent-tmux check`, `board --config ~/.config/board/board.toml once`, full `desktop/tools/qs-menu-smoke`, and full `desktop/tools/desktop-doctor`.
  - Current behavior: `ai-stack-doctor` lives under `desktop/tools`, `check-agents` is merged into `agent-tmux check`, live stale `~/bin/check-agents` and `~/bin/ai-stack-doctor` were archived out of PATH, board scheduler was restarted with the updated config, and full `desktop-doctor` passes while skipping the audio self-test during active helper playback.
